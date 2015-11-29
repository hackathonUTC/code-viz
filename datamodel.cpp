#include "datamodel.h"

#include <QJsonArray>
#include <QJsonObject>
#include "dataobjects.h"

QList<QObject *> DataModel::queryClasses()
{
    QList<QObject*> result;
    QJsonArray jClasses = _dataSource.listClasses();

    result.reserve(jClasses.size());

    for(QJsonValue jClass : jClasses)
    {
        QString className = jClass.toString();

        ClassObject* classObj = new ClassObject();
        classObj->setName(className);
        classObj->setCentrality(_degrees[className] / _maxDegree);

        result.append(classObj);
    }
    return result;
}

QList<QObject *> DataModel::queryMethods(QString className)
{
    QList<QObject*> result;
    QJsonArray jMethods = _dataSource.listClassMethods(className);
    result.reserve(jMethods.size());

    for(QJsonValue jMethod : jMethods)
    {
        QJsonObject jObj = jMethod.toObject();
        QString methodName = jObj["name"].toString();
        QString visibility = jObj["visibility"].toString();

        MethodObject* methodObj = new MethodObject();
        methodObj->setName(methodName);
        methodObj->setVisibility(visibility);

        result.append(methodObj);
    }
    return result;
}

QList<QObject *> DataModel::queryAttributes(QString className)
{
    QList<QObject*> result;
    QJsonArray jAttributes = _dataSource.listClassAttributes(className);
    result.reserve(jAttributes.size());

    for(QJsonValue jAttribute: jAttributes)
    {
        QJsonObject jObj = jAttribute.toObject();
        QString attributeName = jObj["name"].toString();
        QString type = jObj["type"].toString();

        AttributeObject* attributeObj = new AttributeObject();
        attributeObj->setName(attributeName);
        attributeObj->setType(type);

        result.append(attributeObj);
    }
    return result;
}

QList<QObject *> DataModel::queryCallsInsideClass(QString className)
{
    QList<QObject*> result;
    QJsonArray jCalls = _dataSource.listLinksCallsInside(className);
    result.reserve(jCalls.size());

    for(QJsonValue jCall: jCalls)
    {
        QJsonObject jObj = jCall.toObject();
        QString methodFrom = jObj["methodFrom"].toString();
        QString methodTo = jObj["methodTo"].toString();

        LinkObject* linkObj = new LinkObject();
        linkObj->setType("calls");

        linkObj->setClassFrom(className);
        linkObj->setClassTo(className);
        linkObj->setMethodFrom(methodFrom);
        linkObj->setMethodTo(methodTo);

        result.append(linkObj);
    }
    return result;
}

QList<QObject *> DataModel::queryCallsOutsideClass(QString className)
{
    QList<QObject*> result;
    QJsonArray jCalls = _dataSource.listLinksCallsOutside(className);
    result.reserve(jCalls.size());

    for(QJsonValue jCall: jCalls)
    {
        QJsonObject jObj = jCall.toObject();
        QString methodFrom = jObj["methodFrom"].toString();
        QString methodTo = jObj["methodTo"].toString();
        QString classTo = jObj["classTo"].toString();

        LinkObject* linkObj = new LinkObject();
        linkObj->setType("calls");
        linkObj->setClassFrom(className);
        linkObj->setClassTo(classTo);

        linkObj->setMethodFrom(methodFrom);
        linkObj->setMethodTo(methodTo);

        result.append(linkObj);
    }
    return result;
}


QList<QObject *> DataModel::queryMethodReferences(QString className, QString methodName)
{
    QList<QObject*> result;
    QJsonArray jReferences = _dataSource.listLinksReferences(className, methodName);
    result.reserve(jReferences.size());

    for(QJsonValue jReference: jReferences)
    {
        QJsonObject jObj = jReference.toObject();
        QString attribute = jObj["attribute"].toString();

        LinkObject* linkObj = new LinkObject();
        linkObj->setType("references");
        linkObj->setClassName(className);
        linkObj->setMethod(methodName);

        linkObj->setAttribute(attribute);

        result.append(linkObj);
    }
    return result;
}

QList<QObject *> DataModel::queryInherits(QString className)
{
    QList<QObject*> result;
    QJsonArray jInheritances = _dataSource.listLinksInherits(className);
    result.reserve(jInheritances.size());

    for(QJsonValue jInheritance : jInheritances)
    {
        QJsonObject jObj = jInheritance.toObject();
        QString classTo = jObj["classTo"].toString();


        LinkObject* linkObj = new LinkObject();
        linkObj->setType("inherits");
        linkObj->setClassFrom(className);

        linkObj->setClassTo(classTo);
        //qDebug() << classTo;

        result.append(linkObj);
    }
    return result;
}


DataModel::DataModel()
{
    computeDegreeCentrality();
}

void DataModel::computeDegreeCentrality()
{
    _maxDegree = 0.f;
    QJsonArray classes = _dataSource.listClasses();

    const float intraClassCallWeight = 0.5f;
    const float extraClassCallWeight = 1.f;
    const float inheritanceWeight = 1.f;

    for(QJsonValue oneClass : classes)
    {
        QString className = oneClass.toString();
        _degrees.insert(className, 0.f);
    }

    for(QJsonValue oneClass : classes)
    {
        QString className = oneClass.toString();
        float& degree = _degrees[className];

        // Initial weight is 1;
        degree += 1.f;

        QJsonArray internalCalls = _dataSource.listLinksCallsInside(className);
        degree += internalCalls.size() * intraClassCallWeight;

        QJsonArray externalCalls = _dataSource.listLinksCallsOutside(className);
        degree += externalCalls.size() * extraClassCallWeight;
        for(QJsonValue call : externalCalls)
        {
            QString otherClass = call.toObject()["classTo"].toString();
            _degrees[otherClass] += extraClassCallWeight;
        }

        QJsonArray inheritsFrom = _dataSource.listLinksInherits(className);
        for(QJsonValue parentClass : inheritsFrom)
        {
            QString parentName = parentClass.toObject()["classTo"].toString();
            _degrees[parentName] += inheritanceWeight;
        }
    }

    foreach(float degree, _degrees)
    {
        if(_maxDegree < degree)
            _maxDegree = degree;
    }
}

