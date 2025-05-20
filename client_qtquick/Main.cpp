#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QObject>
#include <QtProtobufQtCoreTypes>

class FileWriter : public QObject
{
    Q_OBJECT
public:
    using QObject::QObject;

    Q_INVOKABLE bool save(const QString &path, const QByteArray &data)
    {
        QDir dir(QFileInfo(path).absolutePath());
        if (!dir.exists())
            dir.mkpath(".");
        QFile file(path);
        if (!file.open(QIODevice::WriteOnly))
            return false;
        file.write(data);
        file.close();
        return true;
    }
};

int main(int argc, char *argv[])
{
    QtProtobuf::registerProtobufQtCoreTypes();

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    FileWriter writer;
    engine.rootContext()->setContextProperty("fileWriter", &writer);
    engine.loadFromModule("ClientQtQuick", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

#include "Main.moc"
