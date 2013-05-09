# PDF Ravager [![Build Status](https://secure.travis-ci.org/abevoelker/pdf_ravager.png)](http://travis-ci.org/abevoelker/pdf_ravager)

Provides a simple DSL for easily filling out AcroForms PDF or XFA documents.

## Description

This library uses a combination of a simple DSL and a minimal façade over the
last free version of the iText library to aid in filling out AcroForms PDF or
XFA documents.

## Synopsis

```ruby
require 'pdf_ravager/kernel'

data = {name: 'Bob', gender: 'm', relation: 'Uncle' }

template = pdf do |p|
  p.text      'name', data[:name]
  p.rich_text 'name_stylized', "<b>#{data[:name]}</b>"
  p.fill      'sex', 'male'   if data[:gender] == 'm'
  p.fill      'sex', 'female' if data[:gender] == 'f'
  case data[:relation]
  when 'Mom', 'Dad'
    p.check 'parent'
  when 'Brother', 'Sister'
    p.check 'sibling'
  else
    p.check 'other'
  end
end

template.ravage '/tmp/info.pdf', out_file: '/tmp/info_filled.pdf'
# if you'd like the populated form to be read-only:
template.ravage '/tmp/info.pdf', out_file: '/tmp/info_filled.pdf', read_only: true
```

If you don't want the global `pdf` method, the default `require 'pdf_ravager'`
actually doesn't add it. You just need to be more wordy in this case:

```ruby
require 'pdf_ravager'

data = {name: 'Bob', gender: 'm', relation: 'Uncle' }

template = PDFRavager::Template.new do |p|
  p.text 'name', data[:name]
  # ...
end
```

## Usage

### Field Names
To query and modify a form's field names, use a tool such as Adobe
LiveCycle.

### Rich Text
Rich text is specific to XFA forms. To understand how it should be used,
see the "Rich Text Reference" section of [Adobe's XFA standard][1].
Rich Text is defined there as a subset of
XHTML and CSS which uses some custom restrictions and extensions by
Adobe. The minimum XHTML and CSS elements that a standards-compliant
XFA processor (e.g. Adobe Reader) must support are also listed there
and can be used as a guide.

**Note**: Rich text values are not HTML-escaped or sanitized in any
way. It is suggested that you call `CGI.escape_html` on user-supplied
input.

## Copyright

Copyright (c) 2012-2013 Abe Voelker. Released under the terms of the
MIT license. See LICENSE for details.

The [version of iText][2] vendored is licensed under the LGPL.

[1]: http://partners.adobe.com/public/developer/xml/index_arch.html
[2]: http://itext.svn.sourceforge.net/viewvc/itext/tags/iText_4_2_0/