#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <jsonparser.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    JsonParser parser = JsonParser();



    return app.exec();
}

