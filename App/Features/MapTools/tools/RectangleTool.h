#ifndef RECTANGLETOOL_H
#define RECTANGLETOOL_H

#include <QObject>
#include "BaseTool.h"

class RectangleTool : public BaseTool
{
    Q_OBJECT

public:
    explicit RectangleTool(QObject* parent = nullptr);

    void clear();
};

#endif // RECTANGLETOOL_H
