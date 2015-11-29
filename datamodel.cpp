#include "datamodel.h"

#include <QJsonArray>
#include <QJsonObject>
#include "dataobjects.h"

#include <QDebug>

#include <qmath.h>

#define DEC 20

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

    computePositions();
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

void DataModel::computePositions()
{
    class ClassPair : public QPair<QString, float>
    {
    public:
        ClassPair(QString x, float y) : QPair<QString, float>(x, y) {}
        bool operator<(const ClassPair& other) const
        {
            return second > other.second; // we want the biggest value first
        }
    };

    QList<ClassPair> sortedClasses;
    auto keys = _degrees.keys();
    auto values = _degrees.values();
    sortedClasses.reserve(keys.size());
    for(int i = 0 ; i < keys.size() ; ++i)
    {
        ClassPair classValue(keys[i], values[i]);
        sortedClasses.append(classValue);
    }

    qSort(sortedClasses.begin(), sortedClasses.end());




    // Calcul des positions des ClassBox
    int nombre_de_centres = ((sortedClasses[2].second / sortedClasses[1].second) > 0.95f || (sortedClasses[1].second / sortedClasses[0].second) < 0.8f) ? 1 : 2;

    // Let's set the biggest(s) one(s)
    float R = sortedClasses[0].second * 25; // 25 taille de base du classBox
    if (nombre_de_centres == 1)
        _positions.insert(sortedClasses[0].first, QPoint(0, 0));
    else
    {
        float* d = new float[2];
        dist(1, 1, R, 0, d);
        _positions.insert(sortedClasses[0].first, QPoint((int) (d[0]/2.f * sortedClasses[1].second/sortedClasses[0].second + DEC), 0));
        _positions.insert(sortedClasses[1].first, QPoint((int) (-d[0]/2.f * sortedClasses[0].second/sortedClasses[1].second + DEC), 0));
    }

    // Consider the other classes, ordering by cov decreasing with the biggest(s)
    // Replacing
    int i = 2;
    QList<ClassPair> sortedCovar = sortedClasses;
    if (nombre_de_centres == 1)
    {
        // Calculating covar with 1 center
        for (; i < keys.size(); ++i)
            sortedCovar[i].second = closeness(sortedCovar[i].first, sortedCovar[0].first);

        // Ordering (with naive algortihm...)
        for (i = 2; i < keys.size() - 1; ++i)
        {
            float covmax = sortedCovar[i].second;
            int j = i + 1;
            int indexmax = i;
            for (; j < keys.size(); ++j){
                if (covmax < sortedCovar[j].second)
                {
                    indexmax = j;
                    covmax = sortedCovar[j].second;
                }
            }
            ClassPair temp = sortedClasses[i];
            sortedClasses[i].first = sortedClasses[indexmax].first;
            sortedClasses[i].second = covmax;
            sortedClasses[indexmax] = temp;
        }

        // Array ordered by now. Calculating locations of all classes
        i = nombre_de_centres;
        float angle = 0;
        for (; i < keys.size(); ++i)
        {
            float* d = new float[2];
            dist(sortedCovar[i].second, sortedCovar[2].second, R, angle, d);
            _positions.insert(sortedClasses[i].first, QPoint((int) d[0], (int) d[1]));
            angle += 7 * M_PI / 6;
        }
    }
    else
    {
        // Calculating covar with 2 center
        for (; i < keys.size(); ++i)
            sortedCovar[i].second = closeness(sortedCovar[i].first, sortedCovar[0].first) + closeness(sortedCovar[i].first, sortedCovar[1].first) * sortedClasses[1].second / sortedClasses[0].second;

        // Ordering (with naive algortihm...)
        for (i = 2; i < keys.size() - 1; ++i)
        {
            float covmax = sortedCovar[i].second;
            int j = i + 1;
            int indexmax = i;
            for (; j < keys.size(); ++j){
                if (covmax < sortedCovar[j].second)
                {
                    indexmax = j;
                    covmax = sortedCovar[j].second;
                }
            }
            ClassPair temp = sortedClasses[i];
            sortedClasses[i].first = sortedClasses[indexmax].first;
            sortedClasses[i].second = covmax;
            sortedClasses[indexmax] = temp;
        }

        // Array ordered by now. Calculating locations of all classes
        _positions.insert(sortedClasses[2].first, QPoint(0, -20));
        float angle = 7 * M_PI / 6;
        for (i = 3; i < keys.size(); ++i)
        {
            float* d = new float[2];
            dist(sortedCovar[i].second, sortedCovar[2].second, R, angle, d);
            _positions.insert(sortedClasses[i].first, QPoint((int) d[0], (int) d[1]));
            angle += 7 * M_PI / 6;
        }
    }
}

float DataModel::closeness(QString class1, QString class2){
    float value = 0.f;
    QJsonArray inherits1 = _dataSource.listLinksInherits(class1);
    for(QJsonValue it : inherits1)
    {
        if(it.toObject()["classTo"] == class2)
            value += 1.f;
    }

    QJsonArray inherits2 = _dataSource.listLinksInherits(class2);
    for(QJsonValue it : inherits2)
    {
        if(it.toObject()["classTo"] == class1)
            value += 1.f;
    }

    QJsonArray methodCalls1 = _dataSource.listLinksCallsOutside(class1);
    for(QJsonValue it : methodCalls1)
    {
        if(it.toObject()["classTo"] == class2)
            value += 0.2f;
    }

    QJsonArray methodCalls2 = _dataSource.listLinksCallsOutside(class2);
    for(QJsonValue it : methodCalls2)
    {
        if(it.toObject()["classTo"] == class1)
            value += 0.2f;
    }

    return value;
}

void DataModel::dist(float cov1, float covmax /* max des covariances de la ligne de cov1*/, float R, float angle, float res[2])
{
    float tmp = qMin(0.01f, covmax / cov1) * R;
    res[0] = tmp * cos(angle);
    res[1] = tmp * sin(angle);
}



