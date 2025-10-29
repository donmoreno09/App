#ifndef ELLIPSETOOL_H
#define ELLIPSETOOL_H

#include <QObject>
#include "BaseTool.h"

class EllipseTool : public BaseTool
{
    Q_OBJECT

public:
    explicit EllipseTool(QObject *parent = nullptr);

    void clear();
};

#endif // ELLIPSETOOL_H
