#ifndef CCMiniHtmlParser_h__
#define CCMiniHtmlParser_h__

#include <string>
#include <vector>

#define MAX_HTML_DATA_LEN 8192


class SFMiniHtmlParser
{
public:
	struct Attr
	{
		std::string key;
		std::string value;
	};

	struct Atom
	{
		std::string atom_name;
		std::vector<Attr> attr_list;
	};

	struct Data
	{
		bool is_special_flag;
		std::string data;
		std::vector<Atom> atom_list;
	};

	typedef std::vector<Data> DataArray;

public:
	SFMiniHtmlParser();
	~SFMiniHtmlParser();

	const DataArray& Parse(const char *s);

private:
	const char *DataParse(const char *s, const char *end_str, bool recursion_atom);

	void ToData(const char *beg, const char *end);
	const char *Str(const char *s);
	const char *AtomNameParse(const char *s);
	const char *AttrNameParse(const char *s);
	bool AtomParse(const char *s, const char **out_s);
	void AddDataSegment( int data_index, bool has_special_flag );
	void ResetData();

private:
	char m_data[MAX_HTML_DATA_LEN];
	int m_data_len;
	std::vector<Atom> m_atom_stack;
	DataArray m_data_list;
};

#endif // DreamMiniHtml_h__
