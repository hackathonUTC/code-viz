#ifndef JSONPARSER_H
#define JSONPARSER_H

#include <QJsonArray>
#include <QString>


class JsonParser
{
private:
    QJsonArray _classesArray;
    QJsonArray _linksArray;


public:
    JsonParser();
    ~JsonParser();
    QJsonArray listClasses();
    QJsonArray listClassAttributes(QString classRequested);
    QJsonArray listClassMethods(QString classRequested);
    QJsonArray listLinksCallsInside(QString classRequested);
    QJsonArray listLinksCallsOutside(QString classRequested);
    QJsonArray listLinksReferences(QString classRequested, QString methodName);
    QJsonArray listLinksInherits(QString classRequested);
    QJsonArray listLinksInheritsReverse(QString motherClass);

};

#endif // JSONPARSER_H
