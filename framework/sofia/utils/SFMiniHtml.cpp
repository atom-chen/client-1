#include "include/utils/SFMiniHtml.h"


#include <memory.h>

//-------------------------------------------------------------------------
bool IsSpace(char c)
{
	return c == ' ' || c == '\t';
}

const char *Eat(const char *s)
{
	while(s != 0 && IsSpace(*s)) ++s;
	return s;
}

bool BeginWith(const char *s, const char *beg)
{
	while(*beg != 0 && *s != 0 && *beg == *s)
	{
		++beg;
		++s;
	}
	return *beg == 0;
}

//-------------------------------------------------------------------------

SFMiniHtmlParser::SFMiniHtmlParser():m_data_len(0)
{
	memset(m_data, 0 , MAX_HTML_DATA_LEN);
}

SFMiniHtmlParser::~SFMiniHtmlParser()
{

}


void SFMiniHtmlParser::ToData(const char *beg, const char *end)
{
	m_data_len = int(end - beg);
	if (m_data_len != 0) 
	{
		memcpy(m_data, beg, m_data_len);
	}
	m_data[m_data_len] = 0;
}



const char *SFMiniHtmlParser::Str(const char *s)
{
	const char *beg = s;
	char c = *s;
	while(c != 0 && ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c == '_')))
	{
		c = *(++s);
	}
	ToData(beg, s);
	return s;
}




const char *SFMiniHtmlParser::DataParse(const char *s, const char *end_str, bool recursion_atom)
{
	int data_index = (int)m_data_list.size();

	char end = end_str[0];

	const char *data_beg = s;
	const char *beg = s;
	char c = *s;
	while(c != 0)
	{
		if (c == end)
		{
			if (beg != s)
			{
				if (*(s - 1) != '\\' && BeginWith(s, end_str))
				{
					break;
				}
			}
			else
			{
				if (BeginWith(s, end_str))
				{
					break;
				}
			}
		}

		if (c == '<')
		{
			int special_len = 0;
			if (BeginWith(s, "<br>"))
			{
				special_len = 4;
			}
			else if (BeginWith(s, "<br/>"))
			{
				special_len = 5;
			}

			if (special_len != 0)
			{
				if (data_beg != s)
				{
					ToData(data_beg, s);
					AddDataSegment(data_index, false);
					data_index = (int)m_data_list.size();
				}

				ToData(s, s + special_len);
				AddDataSegment(data_index, true);
				data_index = (int)m_data_list.size();

				s += special_len;

				data_beg = s;
					
				c = *(s);
				continue;
			}
		}

		const char *data_end = s;
		if (recursion_atom && AtomParse(s, &s))
		{
			ToData(data_beg, data_end);
			data_beg = s;

			if (m_data_len != 0)
			{
				AddDataSegment(data_index, false);
			}
			data_index = (int)m_data_list.size();
		}
		else
		{
			++s;
		}

		c = *(s);
	}

	if(data_beg != s)
	{
		ToData(data_beg, s);

		if (recursion_atom && m_data_len != 0)
		{
			AddDataSegment(data_index, false);
		}
	}

	return s;
}

const char *SFMiniHtmlParser::AtomNameParse(const char *s)
{
	return Str(s);
}

const char *SFMiniHtmlParser::AttrNameParse(const char *s)
{
	return Str(s);
}

bool SFMiniHtmlParser::AtomParse(const char *s, const char **out_s)
{
	//s = Eat(s);

	if (*s == 0)
	{
		*out_s = s;
		return true;
	}

	if (*s++ != '<') return false;

	s = AtomNameParse(s);
	if (m_data_len == 0) return false;

	int atom_index = (int)m_atom_stack.size();
	Atom atom;
	atom.atom_name = m_data;
	m_atom_stack.push_back(atom);

	// get attr name

	bool end_mark = false;

	while(true)
	{
		s = Eat(s);

		char t = *s;
		if (t == '/')
		{
			++s;
			if (*s == '>')
			{
				++s;
				end_mark = true;
				break;
			}
			else
			{
				m_atom_stack.pop_back();
				return false;
			}
		}
		if (t == '>')
		{
			++s;
			end_mark = false;
			break;
		}

		s = AttrNameParse(s);
		if (m_data_len == 0)
		{
			m_atom_stack.pop_back();
			return false;
		}

		// get key
		Attr attr;
		attr.key = m_data;

		s = Eat(s);
		if (*s++ != '=')
		{
			m_atom_stack.pop_back();
			return false;
		}

		s = Eat(s);
		t = *s;
		if (t == '\'')
		{
			++s;
			s = DataParse(s, "'", false);
			if (*s++ != '\'')
			{ 
				m_atom_stack.pop_back();
				return false;
			}

			// get value
			attr.value = m_data;
			m_atom_stack[atom_index].attr_list.push_back(attr);
		}
		else if (t == '"')
		{
			++s;
			s = DataParse(s, "\"", false);
			if (*s++ != '"')
			{
				m_atom_stack.pop_back();
				return false;
			}

			// get value
			attr.value = m_data;
			m_atom_stack[atom_index].attr_list.push_back(attr);
		}
		else
		{
			m_atom_stack.pop_back();
			return false;
		}
	}

	if (!end_mark)
	{
		s = DataParse(s, "</", true);

		if (*s++ != '<' || *s++ != '/')
		{
			m_atom_stack.pop_back();
			return false;
		}
		s = AttrNameParse(s);
		s = Eat(s);
		if (*s++ != '>' ) 
		{
			m_atom_stack.pop_back();
			return false;
		}
	}
	else
	{
		ResetData();
		AddDataSegment((int)(m_data_list.size()), false);
	}

	m_atom_stack.pop_back();

	*out_s = s;
	return true;
}

const SFMiniHtmlParser::DataArray&  SFMiniHtmlParser::Parse( const char *s )
{
	m_data_list.clear();
	m_atom_stack.clear();

	DataParse(s, "", true);

	return m_data_list;
}

void SFMiniHtmlParser::AddDataSegment( int data_index, bool is_special_flag )
{
	Data data;
	data.data = m_data;
	data.is_special_flag = is_special_flag;
	data.atom_list = m_atom_stack;
	m_data_list.insert(m_data_list.begin() + data_index, data);
}

void SFMiniHtmlParser::ResetData()
{
	memset(m_data, 0 , sizeof(m_data));
	m_data_len = 0;
}