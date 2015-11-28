#ifndef DATAOBJECTS_H
#define DATAOBJECTS_H

#include <QObject>

class ClassObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName)
    QString m_name;

public:
    QString name() const { return m_name; }
    void setName(const QString &name) {
        m_name = name;
    }
};




class MethodObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(QString visibility READ visibility WRITE setVisibility)

    QString m_name;

    QString m_visibility;

public:
QString name() const
{
    return m_name;
}
QString visibility() const
{
    return m_visibility;
}

public slots:
void setName(QString name)
{
    m_name = name;
}
void setVisibility(QString visibility)
{
    m_visibility = visibility;
}
};



class AttributeObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(QString type READ type WRITE setType)

    QString m_name;

    QString m_type;

public:
QString name() const
{
    return m_name;
}
QString type() const
{
    return m_type;
}

public slots:
void setName(QString name)
{
    m_name = name;
}
void setType(QString type)
{
    m_type = type;
}
};



class LinkObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)

    // For links of type "calls"
    Q_PROPERTY(QString classFrom READ classFrom WRITE setClassFrom)
    Q_PROPERTY(QString methodFrom READ methodFrom WRITE setMethodFrom)
    Q_PROPERTY(QString classTo READ classTo WRITE setClassTo)
    Q_PROPERTY(QString methodTo READ methodTo WRITE setMethodTo)

    // For links of type "references"
    Q_PROPERTY(QString className READ className WRITE setClassName)
    Q_PROPERTY(QString method READ method WRITE setMethod)
    Q_PROPERTY(QString attribute READ attribute WRITE setAttribute)

    // For "inherits", properties classFrom and classTo are already defined

    QString m_classFrom;

    QString m_methodFrom;

    QString m_classTo;

    QString m_methodTo;

    QString m_className;

    QString m_method;

    QString m_attribute;

    QString m_type;

public:
QString classFrom() const
{
    return m_classFrom;
}
QString methodFrom() const
{
    return m_methodFrom;
}

QString classTo() const
{
    return m_classTo;
}

QString methodTo() const
{
    return m_methodTo;
}

QString className() const
{
    return m_className;
}

QString method() const
{
    return m_method;
}

QString attribute() const
{
    return m_attribute;
}

QString type() const
{
    return m_type;
}

public slots:
void setClassFrom(QString classFrom)
{
    if (m_classFrom == classFrom)
        return;

    m_classFrom = classFrom;
}
void setMethodFrom(QString methodFrom)
{
    if (m_methodFrom == methodFrom)
        return;

    m_methodFrom = methodFrom;
}

void setClassTo(QString classTo)
{
    if (m_classTo == classTo)
        return;

    m_classTo = classTo;
}

void setMethodTo(QString methodTo)
{
    if (m_methodTo == methodTo)
        return;

    m_methodTo = methodTo;
}

void setClassName(QString className)
{
    if (m_className == className)
        return;

    m_className = className;
}

void setMethod(QString method)
{
    if (m_method == method)
        return;

    m_method = method;
}

void setAttribute(QString attribute)
{
    if (m_attribute == attribute)
        return;

    m_attribute = attribute;
}
void setType(QString type)
{
    if (m_type == type)
        return;

    m_type = type;
    emit typeChanged(type);
}
signals:
void typeChanged(QString type);
};

#endif // DATAOBJECTS_H
