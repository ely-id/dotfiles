#pragma once

#include <QDir>
#include <QDrag>
#include <QGuiApplication>
#include <QMimeData>
#include <QPainter>
#include <QPainterPath>
#include <QQuickItem>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QTemporaryFile>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <memory>

class ScreenshotMimeData final : public QMimeData {
public:
    std::shared_ptr<bool> transferred = std::make_shared<bool>(false);

protected:
    QVariant retrieveData(const QString &type, QMetaType preferredType) const override {
        if (type == "image/png" || type == "text/uri-list") *transferred = true;
        return QMimeData::retrieveData(type, preferredType);
    }
};

class ScreenshotDrag : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    using QObject::QObject;

    // `radius` é o raio do desenho que acompanha o ponteiro, em pixels lógicos: quem chama passa o da prévia
    // (Theme.capturePreviewRadius), e nenhum valor de desenho fica aqui.
    Q_INVOKABLE bool start(QQuickItem *source, const QString &imageSource, const QPointF &hotSpot, qreal radius) {
        if (!source || !source->window()) return false;
        // A prévia entrega a imagem como data URL em PNG; qualquer outro prefixo eu recuso.
        static const QString prefix = QStringLiteral("data:image/png;base64,");
        if (!imageSource.startsWith(prefix)) return false;
        const QByteArray png = QByteArray::fromBase64(imageSource.mid(prefix.size()).toLatin1());
        const QImage image = QImage::fromData(png, "PNG");
        if (image.isNull()) return false;

        const QString directory = QStandardPaths::writableLocation(QStandardPaths::RuntimeLocation)
            + "/wintermute-shell";
        if (!QDir().mkpath(directory)) return false;
        QFile::setPermissions(directory, QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner);
        QTemporaryFile file(directory + "/Screenshot-XXXXXX.png");
        if (!file.open() || file.write(png) != png.size() || !file.flush()) return false;
        file.close();

        auto *mime = new ScreenshotMimeData;
        mime->setData("image/png", png);
        mime->setUrls({QUrl::fromLocalFile(file.fileName())});
        const auto transferred = mime->transferred;
        auto *drag = new QDrag(source);
        drag->setMimeData(mime);

        const qreal scale = source->window()->devicePixelRatio();
        const QSize size = QSizeF(source->width(), source->height()).toSize();
        const QSize pixels = size * scale;
        const QImage scaled = image.scaled(pixels, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation);
        QPixmap preview(pixels);
        preview.setDevicePixelRatio(scale);
        preview.fill(Qt::transparent);
        {
            QPainter painter(&preview);
            painter.setRenderHint(QPainter::Antialiasing);
            QPainterPath clip;
            clip.addRoundedRect(QRectF(QPointF(), size), radius, radius);
            painter.setClipPath(clip);
            const QRect crop((scaled.width() - pixels.width()) / 2,
                             (scaled.height() - pixels.height()) / 2, pixels.width(), pixels.height());
            painter.drawImage(QRectF(QPointF(), size), scaled, crop);
        }
        drag->setPixmap(preview);
        drag->setHotSpot(hotSpot.toPoint());
        const Qt::DropAction action = drag->exec(Qt::CopyAction, Qt::CopyAction);

        // Quem recebe um arquivo pode abrir a URL depois de o arraste terminar: por isso o arquivo fica mais 60 s.
        file.setAutoRemove(false);
        QTimer::singleShot(60000, qApp, [path = file.fileName()] { QFile::remove(path); });
        // No Wayland o destino pode ler os dados e mesmo assim terminar com IgnoreAction: por isso também conto a leitura.
        return action == Qt::CopyAction || *transferred;
    }
};
