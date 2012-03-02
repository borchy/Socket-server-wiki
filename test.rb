# encoding: utf-8
require "./formatter"
require "test/unit"

class TestFormatter < Test::Unit::TestCase
  def compare(input, result)
    assert_equal(result, Formatter::markdown_to_html(input))
  end
  
  def test_paragraphs
    input = "one two three"
    output = "<p>one two three</p>"
    compare(input, output)

    input = <<-END
First line.

Second line.

Third line.
END
    output = <<-END
<p>First line.</p>
<br/>
<p>Second line.</p>
<br/>
<p>Third line.</p>
END
    compare(input, output)

    input = <<-END
First line.
Second line.
Third line.

Last line, of course.
END
    output = <<-END
<p>First line.<br/>
Second line.<br/>
Third line.</p>
<br/>
<p>Last line, of course.</p>
END
    compare(input, output)

    compare("", "")

    input = <<-END
Cats & Cash

Cool, <right>?
END
    output = <<-END
<p>Cats &amp; Cash</p>
<br/>
<p>Cool, &lt;right&gt;?</p>
END
    compare(input, output)

    input = <<-END
First line.
# Header...
Third line.

Separate line
END
    output = <<-END
<p>First line.</p>
<h1>Header...</h1>
<p>Third line.</p>
<br/>
<p>Separate line</p>
END
    compare(input, output)
  end

  def test_headers
    compare('# This one is an H1', '<h1>This one is an H1</h1>')
    compare('## This one is an H2', '<h2>This one is an H2</h2>')
    compare('### This one is an H3', '<h3>This one is an H3</h3>')
    compare('#### This one is an H4', '<h4>This one is an H4</h4>')

    compare('#No whitespace!', '<p>#No whitespace!</p>')
    compare('##### Header TOO small', '<p>##### Header TOO small</p>')
    # FIX
    #compare('###   ', '<p>###</p>')

    compare('### This one is an H3 ###', '<h3>This one is an H3 ###</h3>')
    compare('#### This one is # an H4', '<h4>This one is # an H4</h4>')
    compare('   ## Leading wsp', '<h2>Leading wsp</h2>')
    compare('## Trailing wsp  ', '<h2>Trailing wsp</h2>')
    compare('  ## Both l and tr  ', '<h2>Both l and tr</h2>')

    compare('## Cash & "Carry me away"...', '<h2>Cash &amp; &quot;Carry me away&quot;...</h2>')
  end

  def test_code_blocks
    compare('    This one is a simple code block', '<pre><code>This one is a simple code block</code></pre>')

    input = <<-END
    require 'gravity'
    
    # I'm flying! Just like in Python!
END
    output = <<-END
<pre><code>require 'gravity'

# I'm flying! Just like in Python!</code></pre>
END
    compare(input, output)

    input = <<-END
    First code-block

    Second block of code
END
    output = <<-END
<pre><code>First code-block</code></pre>
<br/>
<pre><code>Second block of code</code></pre>
END
    compare(input, output)

    compare('    quote = "Simple & efficient";', '<pre><code>quote = &quot;Simple &amp; efficient&quot;;</code></pre>')

    input = <<-END
    // Пример за блок с код.
    // В него всеки ред, дори празните, е предшестван от точно четири интервала.
    include <stdio.h>
    
    int main(int, char**) {
    \t// Whitespace след четирите задължителни интервала в началото, се запазва винаги.
    \treturn 42;
    }
END
    output = <<-END
<pre><code>// Пример за блок с код.
// В него всеки ред, дори празните, е предшестван от точно четири интервала.
include &lt;stdio.h&gt;

int main(int, char**) {
\t// Whitespace след четирите задължителни интервала в началото, се запазва винаги.
\treturn 42;
}</code></pre>
END
    compare(input, output)

    input = <<-END
# This is a header

Some parahraphs here

    Some clean code
    Which is also beautiful
    And maybe also compiles!

More paragraphs there?
END
    output = <<-END
<h1>This is a header</h1>
<br/>
<p>Some parahraphs here</p>
<br/>
<pre><code>Some clean code
Which is also beautiful
And maybe also compiles!</code></pre>
<br/>
<p>More paragraphs there?</p>
END
    compare(input, output)
  end

  def test_blockquotes
    compare('> Simple quote', '<blockquote><p>Simple quote</p></blockquote>')

    input = <<-END
> First line.
> Second line.
> Third line.
END
    output = <<-END
<blockquote><p>First line.<br/>
Second line.<br/>
Third line.</p></blockquote>
END
    compare(input, output)

    input = <<-END
> First quote.

> Second quote.
END
    output = <<-END
<blockquote><p>First quote.</p></blockquote>
<br/>
<blockquote><p>Second quote.</p></blockquote>
END
    compare(input, output)

    input = <<-END
> First quote.
> 
> Second quote.
END
    output = <<-END
<blockquote><p>First quote.</p>
<br/>
<p>Second quote.</p></blockquote>
END
    compare(input, output)

    compare('> Cuttin & Pastin, w/o Quotin (")', '<blockquote><p>Cuttin &amp; Pastin, w/o Quotin (&quot;)</p></blockquote>')
  end

  def test_links
    compare '[Programming in Ruby](http://fmi.ruby.bg/)', '<p><a href="http://fmi.ruby.bg/">Programming in Ruby</a></p>'

    compare 'Въпрос? [Има Google](http://google.com/) за тази цел.', '<p>Въпрос? <a href="http://google.com/">Има Google</a> за тази цел.</p>'

    # FIX
#  compare 'We have [a first](some-url) and [Second](another-url).', '<p>We have <a href="some-url">a first</a> and <a href="another-url">Second</a>.</p>'

  compare 'This one is [clearly] (broken)!', '<p>This one is [clearly] (broken)!</p>'
  compare 'This one [is broken (too)]!', '<p>This one [is broken (too)]!</p>'
  compare 'The wind [is blowing (here)!', '<p>The wind [is blowing (here)!</p>'

  compare '    This one [is a link](in-a-code-block) - keep as-is.', '<pre><code>This one [is a link](in-a-code-block) - keep as-is.</code></pre>'

  compare 'Also testing [special & "entities" <b>](here).', '<p>Also testing <a href="here">special &amp; &quot;entities&quot; &lt;b&gt;</a>.</p>'
  
  compare 'Or [what if](special & "entities" <b>) are in the URL, eh?', '<p>Or <a href="special &amp; &quot;entities&quot; &lt;b&gt;">what if</a> are in the URL, eh?</p>'
  end

  def test_lists
    input = <<-END
* Едно.
* Друго.
* Трето...
END
    output = <<-END
<ul>
  <li>Едно.</li>
  <li>Друго.</li>
  <li>Трето...</li>
</ul>
END
    compare input, output
    
    input = <<-END
1. Първо.
2. Второ.
3. Трето...
END
    output = <<-END
<ol>
  <li>Първо.</li>
  <li>Второ.</li>
  <li>Трето...</li>
</ol>
END
    compare input, output
    
    input = <<-END
* Single item.
END
    output = <<-END
<ul>
  <li>Single item.</li>
</ul>
END
    compare input, output

    input = <<-END
1. Single item.
END
    output = <<-END
<ol>
  <li>Single item.</li>
</ol>
END
    compare input, output
    
    input = <<-END
1) Първо.
2 Второ.
3.Трето
4. Четвърто
END
    output = <<-END
<p>1) Първо.<br/>
2 Второ.<br/>
3.Трето</p>
<ol>
  <li>Четвърто</li>
</ol>
END
    compare input, output
    
    input = <<-END
* The && and || are logical operators
* The `"` symbol
END
    output = <<-END
<ul>
  <li>The &amp;&amp; and || are logical operators</li>
  <li>The `&quot;` symbol</li>
</ul>
END
    compare input, output
    
    input = <<-END
* A [simple link]( here ) or there?
END
    output = <<-END
<ul>
  <li>A <a href=" here ">simple link</a> or there?</li>
</ul>
END
    compare input, output
  end

  def test_bold_italic
    compare '_Simplest_ case', '<p><em>Simplest</em> case</p>'
    compare '_Simplest case_', '<p><em>Simplest case</em></p>'
    compare '**Simplest case**', '<p><strong>Simplest case</strong></p>'
    
    compare 'Some _more words here_ _to be_ **emphasized**, okay?','<p>Some <em>more words here</em> <em>to be</em> <strong>emphasized</strong>, okay?</p>'
    
    compare '# _Simplest_ case', '<h1><em>Simplest</em> case</h1>'
    compare '# _Simplest case_', '<h1><em>Simplest case</em></h1>'
    compare '## **Simplest case**', '<h2><strong>Simplest case</strong></h2>'

    compare '> _Simplest_ case', '<blockquote><p><em>Simplest</em> case</p></blockquote>'
    compare '> _Simplest case_', '<blockquote><p><em>Simplest case</em></p></blockquote>'
    compare '> **Strongest** case', '<blockquote><p><strong>Strongest</strong> case</p></blockquote>'
    
    compare '    Some _more words_ _to be_ **emphasized**?', '<pre><code>Some _more words_ _to be_ **emphasized**?</code></pre>'
    
    compare 'Some [_more words here_ _to be_ **emphasized**](okay)?',
    '<p>Some <a href="okay"><em>more words here</em> <em>to be</em> <strong>emphasized</strong></a>?</p>'
    
    input = '* Some _more words_ _to be_ **emphasized**'
    output = <<-END
<ul>
  <li>Some <em>more words</em> <em>to be</em> <strong>emphasized</strong></li>
</ul>
END
    compare input, output
    
    input = '* Some [_more words_ _to be_ **emphasized**](okay)!'
    output = <<-END
<ul>
  <li>Some <a href="okay"><em>more words</em> <em>to be</em> <strong>emphasized</strong></a>!</li>
</ul>
END
    compare input, output

    compare 'Some _more & words_ _to be_ **"emphasized"**!',
    '<p>Some <em>more &amp; words</em> <em>to be</em> <strong>&quot;emphasized&quot;</strong>!</p>'

    compare 'Some _more words **to be_ emphasized**!',
    '<p>Some <em>more words **to be</em> emphasized**!</p>'
    
    compare 'Some _more words **to be** emphasized_!',
    '<p>Some <em>more words <strong>to be</strong> emphasized</em>!</p>'
    compare 'Some **more words _to be_ emphasized**!',
    '<p>Some <strong>more words <em>to be</em> emphasized</strong>!</p>'
  end

  def test_special_entities
    compare '"Black & Decker"!', '<p>&quot;Black &amp; Decker&quot;!</p>'
    compare '## "Black & Decker"!', '<h2>&quot;Black &amp; Decker&quot;!</h2>'
    compare '    brand = "Black & Decker"!', '<pre><code>brand = &quot;Black &amp; Decker&quot;!</code></pre>'
    compare '> "Black & Decker"!', '<blockquote><p>&quot;Black &amp; Decker&quot;!</p></blockquote>'
    compare '## _"Black & Decker"_!', '<h2><em>&quot;Black &amp; Decker&quot;</em>!</h2>'
  end
end
