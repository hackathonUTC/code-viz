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

private:
    DataModel();
    DataModel(const DataModel& other) {}
    DataModel& operator=(const DataModel& other) {}

    JsonParser _dataSource;
};

#endif // DATAMODEL_H
