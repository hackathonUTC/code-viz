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
    QJsonArray listLinksCalls();
    QJsonArray listLinksReferences();
    QJsonArray listLinksInherits();

};

#endif // JSONPARSER_H
