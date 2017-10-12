#ifndef _MAP_RECT_H_
#define _MAP_RECT_H_

namespace cmap
{
	void GetViewInfo(int cellsize, int viewbegin, int viewsize, int& viewbeginindex, int& viewnum);

	class IntRect
	{
	public:
		/// default constructor, NOTE: does NOT setup components!
		IntRect(){}

		/// construct from values
		IntRect(int _left, int _top, int _right, int _bottom)
			:left(_left), top(_top), right(_right), bottom(_bottom)
		{}

		/// copy constructor
		IntRect(const IntRect& rhs)
		{ this->left = rhs.left;this->top = rhs.top; this->right = rhs.right; this->bottom = rhs.bottom; }

		/// assignment operator
		void operator=(const IntRect& rhs)
		{
			this->left = rhs.left;
			this->right = rhs.right;
			this->top = rhs.top;
			this->bottom = rhs.bottom;
		}

		bool operator == (const IntRect& rhs) const
		{
			return (this->left == rhs.left && this->right == rhs.right && this->top == rhs.top &&	this->bottom == rhs.bottom);
		}

		int lengthsq() const
		{
			int x_l = this->right - this->left;
			int y_l = this->bottom - this->top;
			return x_l * x_l - y_l * y_l;
		}

		void SetLTRB(int l, int t, int r, int b) { this->left = l; this->top = t; this->right = r; this->bottom = b;}
		void SetLTWH(int l, int t, int w, int h) { this->left = l; this->top = t; this->right = l + w; this->bottom = t + h;}
		void SetCenterXYWH(int x, int y, int w, int h) { int hw = w / 2; int hh = h / 2; this->left = x - hw; this->top = y - hh; this->right = x + hw; this->bottom = y + hh;}
		int GetLeft() const { return this->left;}
		int GetRight() const { return this->right;}
		int GetTop() const { return this->top;}
		int GetBottom() const { return this->bottom;}
		int GetWidth() const { return this->right - this->left;}
		int GetHeight() const { return this->bottom - this->top;}
		void SetLeft(int v) { this->left = v;}
		void SetRight(int v) { this->right = v;}
		void SetTop(int v) { this->top = v;}
		void SetBottom(int v) { this->bottom = v;}

		IntRect Intersect(const IntRect& rhs) const
		{
			int l = rhs.left > this->left ? rhs.left : this->left;
			int t = rhs.top > this->top ? rhs.top : this->top;
			int r = rhs.right < this->right ? rhs.right : this->right;
			int b = rhs.bottom < this->bottom ? rhs.bottom : this->bottom;
			return IntRect(l, t, r, b);
		}

		bool IsIntersect(const IntRect& rhs) const
		{
			if (this->left > rhs.right || this->right < rhs.left || this->top > rhs.bottom || this->bottom < rhs.top)
			{
				return false;
			}
			return true;
		}
		bool IsIntersect(int l, int t, int r, int b) const
		{
			if (this->left > r || this->right < l || this->top > b || this->bottom < t)
			{
				return false;
			}
			return true;
		}
		bool IsIntersect(int x, int y) const
		{
			if (this->left > x || this->right < x || this->top > y || this->bottom < y)
			{
				return false;
			}
			return true;
		}

		void UnionToMe(const IntRect& rhs)
		{
			if (rhs.left < this->left)
			{
				this->left = rhs.left;
			}
			if (rhs.top < this->top)
			{
				this->top = rhs.top;
			}
			if (rhs.right > this->right)
			{
				this->right = rhs.right;
			}
			if (rhs.bottom > this->bottom)
			{
				this->bottom = rhs.bottom;
			}
		}

		IntRect Union(const IntRect& rhs) const
		{
			int l = rhs.left < this->left ? rhs.left : this->left;
			int t = rhs.top < this->top ? rhs.top : this->top;
			int r = rhs.right > this->right ? rhs.right : this->right;
			int b = rhs.bottom > this->bottom ? rhs.bottom : this->bottom;
			return IntRect(l, t, r, b);
		}

		bool IsInclude(const IntRect& rhs) const
		{
			return (this->left <= rhs.left && this->top <= rhs.top && this->right >= rhs.right && this->bottom >= rhs.bottom);
		}

		void Empty()
		{
			this->left = 0;
			this->right = -1;
			this->top = 0;
			this->bottom = -1;
		}

		bool IsEmpty() const
		{
			return (this->right < this->left || this->bottom < this->top);
		}

		IntRect GetExpand(int x, int y) const
		{
			return IntRect(this->left - x, this->top - y, this->right + x, this->bottom + y);;
		}

		void Expand(int x, int y)
		{
			this->left -= x;
			this->top -= y;
			this->right += x;
			this->bottom += y;
		}

		void AddOffset(int x, int y)
		{
			this->left += x;
			this->right += x;
			this->top += y;
			this->bottom += y;
		}

		void SubOffset(int x, int y)
		{
			this->left -= x;
			this->right -= x;
			this->top -= y;
			this->bottom -= y;
		}

		int left;
		int top;
		int right;
		int bottom;
	};


	class IntPoint
	{
	public:
		/// default constructor, NOTE: does NOT setup components!
		IntPoint() {}

		/// construct from values
		IntPoint(int _x, int _y)
			:x(_x), y(_y)
		{ }

		/// copy constructor
		IntPoint(const IntPoint& rhs)
			:x(rhs.x), y(rhs.y)
		{ }

		/// assignment operator
		void operator=(const IntPoint& rhs)
		{ 
			this->x = rhs.x; this->y = rhs.y;
		}

		/// equality operator
		bool operator==(const IntPoint& rhs) const
		{ 
			return (this->x == rhs.x && this->y == rhs.y);
		}
		/// equality operator
		bool operator!=(const IntPoint& rhs) const
		{ 
			return (this->x != rhs.x || this->y != rhs.y);
		}

		int lengthsq() const
		{
			return this->x * this->x + this->y * this->y;
		}

		int x;
		int y;
	};

	#define MapCellSize	16
	#define Map2Cell(n)		int(n/MapCellSize)
	#define Cell2Map(n)		int(n*MapCellSize + MapCellSize/2)

}
#endif
