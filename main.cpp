#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");

    engine.loadFromModule("Main", "Main");

    return app.exec();
}
