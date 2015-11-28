#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "datamodel.h"
#include <QtQml>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterSingletonType<DataModel>("codeviz", 1, 0, "DataModel", DataModel::qml_datamodel_singleton_callback);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));


    return app.exec();
}

