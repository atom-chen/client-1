#ifndef _SFGEOMETRY_H_
#define _SFGEOMETRY_H_

class SFPoint 
{
public:
    int x;
    int y;

public:
    SFPoint();
    SFPoint(int x, int y);
    SFPoint(const SFPoint& other);
    SFPoint& operator= (const SFPoint& other);
    void setPoint(int x, int y);
    
	// for lua
	int getX(){return x;}
	int getY(){return y;}
};

class SFSize
{
public:
    int width;
    int height;

public:
    SFSize();
    SFSize(int width, int height);
    SFSize(const SFSize& other);
    SFSize& operator= (const SFSize& other);
    void setSize(int width, int height);

	// for lua
	int getWidth(){return width;}
	int getHeight(){return height;}
};

class SFRect 
{
public:
    SFPoint origin;
    SFSize  size;

public:
    SFRect();    
    SFRect(int x, int y, int width, int height);
    SFRect(const SFRect& other);
    SFRect& operator= (const SFRect& other); 
    void setRect(int x, int y, int width, int height);
    int getMinX() const; /// return the leftmost x-value of current rect
    int getMidX() const; /// return the midpoint x-value of current rect
    int getMaxX() const; /// return the rightmost x-value of current rect
    int getMinY() const; /// return the bottommost y-value of current rect
    int getMidY() const; /// return the midpoint y-value of current rect
    int getMaxY() const; /// return the topmost y-value of current rect

	void setOrigin(int x, int y);
	void setRect(int width, int height);

	bool containsPoint(int x, int y) const;
    bool containsPoint(const SFPoint& point) const;
    bool intersectsRect(const SFRect& rect) const;
 
};



#endif