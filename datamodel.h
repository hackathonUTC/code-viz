#ifndef DATAMODEL_H
#define DATAMODEL_H

#include <QObject>
#include "jsonparser.h"

class QQmlEngine;
class QJSEngine;

class DataModel : public QObject
{
    Q_OBJECT

public:

    static DataModel& getInstance()
    {
        static DataModel _instance;
        return _instance;
    }

    static QObject* qml_datamodel_singleton_callback(QQmlEngine *engine, QJSEngine *scriptEngine) {
            Q_UNUSED(engine) Q_UNUSED(scriptEngine)
            return &getInstance();
    }

    Q_INVOKABLE QList<QObject*> queryClasses();
    Q_INVOKABLE QList<QObject*> queryMethods(QString className);
    Q_INVOKABLE QList<QObject*> queryAttributes(QString className);

    Q_INVOKABLE QList<QObject*> queryCallsInsideClass(QString className);
    Q_INVOKABLE QList<QObject*> queryCallsOutsideClass(QString className);
    Q_INVOKABLE QList<QObject*> queryMethodReferences(QString className, QString methodName);
    Q_INVOKABLE QList<QObject*> queryInherits(QString className);


private:
    DataModel();
    DataModel(const DataModel& other) {}
    DataModel& operator=(const DataModel& other) {}

    JsonParser _dataSource;
};

#endif // DATAMODEL_H
