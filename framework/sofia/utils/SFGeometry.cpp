#include "utils/SFGeometry.h"
#include "sflog.h"

SFPoint::SFPoint(void)
{
    setPoint(0.0f, 0.0f);
}

SFPoint::SFPoint(int x, int y)
{
    setPoint(x, y);
}

SFPoint::SFPoint(const SFPoint& other)
{
    setPoint(other.x, other.y);
}

SFPoint& SFPoint::operator= (const SFPoint& other)
{
    setPoint(other.x, other.y);
    return *this;
}

void SFPoint::setPoint(int x, int y)
{
    this->x = x;
    this->y = y;
}



//////////////////////////////////////////////////////////////////////////
// implementation of SFSize

SFSize::SFSize(void)
{
    setSize(0.0f, 0.0f);
}

SFSize::SFSize(int width, int height)
{
    setSize(width, height);
}

SFSize::SFSize(const SFSize& other)
{
    setSize(other.width, other.height);
}

SFSize& SFSize::operator= (const SFSize& other)
{
    setSize(other.width, other.height);
    return *this;
}

void SFSize::setSize(int width, int height)
{
    this->width = width;
    this->height = height;
}

//////////////////////////////////////////////////////////////////////////
// implementation of SFRect

SFRect::SFRect(void)
{
    setRect(0.0f, 0.0f, 0.0f, 0.0f);
}

SFRect::SFRect(int x, int y, int width, int height)
{
    setRect(x, y, width, height);
}

SFRect::SFRect(const SFRect& other)
{
    setRect(other.origin.x, other.origin.y, other.size.width, other.size.height);
}

SFRect& SFRect::operator= (const SFRect& other)
{
    setRect(other.origin.x, other.origin.y, other.size.width, other.size.height);
    return *this;
}

void SFRect::setRect(int x, int y, int width, int height)
{
    // Only support that, the width and height > 0
    SFAssert(width >= 0.0f && height >= 0.0f, "width and height of Rect must not less than 0.");

    origin.x = x;
    origin.y = y;

    size.width = width;
    size.height = height;
}

void SFRect::setRect( int width, int height )
{
	size.width = width;
	size.height = height;
}


int SFRect::getMaxX() const
{
    return (int)(origin.x + size.width);
}

int SFRect::getMidX() const
{
    return (int)(origin.x + size.width / 2.0);
}

int SFRect::getMinX() const
{
    return origin.x;
}

int SFRect::getMaxY() const
{
    return origin.y + size.height;
}

int SFRect::getMidY() const
{
    return (int)(origin.y + size.height / 2.0);
}

int SFRect::getMinY() const
{
    return origin.y;
}

bool SFRect::containsPoint(const SFPoint& point) const
{
	return containsPoint(point.x, point.y);
}

bool SFRect::containsPoint( int x, int y ) const
{
	bool bRet = false;

	if (x >= getMinX() && x <= getMaxX()
		&& y >= getMinY() && y <= getMaxY())
	{
		bRet = true;
	}

	return bRet;
}


bool SFRect::intersectsRect(const SFRect& rect) const
{
    return !(     getMaxX() < rect.getMinX() ||
             rect.getMaxX() <      getMinX() ||
                  getMaxY() < rect.getMinY() ||
             rect.getMaxY() <      getMinY());
}

void SFRect::setOrigin( int x, int y )
{
	origin.x = x;
	origin.y = y;
}


