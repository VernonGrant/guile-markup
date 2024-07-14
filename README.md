# Guile Markup

A Guile module that makes it easy to generate HTML markup.

## Usage

### Creating a single element:

The `markup-el` procedure provides an easy way to create HTML elements.
It actually does a fair bit more, but for now lets focus on the creation of
single HTML elements.

You can control the type of the element by using the `#:type` argument, it can
be either `sc` (self closing) or `void`. It's also important to note, that the
first string argument will be escaped and obviously it's not intended to contain
any HTML.

<sub>Guile</sub>

```scheme
(markup-el "div")               ;; Default element.
(markup-el "img" #:type 'sc)    ;; Self closing element
(markup-el "meta" #:type 'void) ;; Void element
```

<sub>Result</sub>

```HTML
<div></div>
<img/>
<meta>
```

### Adding attributes to an element:

To add attributes to an element you can use the `#:attrs` argument, it takes a
list of string pairs `("key" . "value")`, a list of strings or a mixture of the
two. Attribute keys and values will be escaped, aside for the values of
attributes that allow JavaScript.

Here's a list of these attributes:

- `onclick`
- `onload`
- `onchange`
- `onsubmit`
- `onmouseover`
- `onkeydown`
- `href`

<sub>Guile</sub>

```scheme
(markup-el "div" #:attrs '(("id" . "sample-id")))
(markup-el "textarea" #:attrs '("disabled"))
(markup-el "img" #:type 'sc #:attrs '(("src" . "https://example.com/cat.jpg")))
(markup-el "meta" #:type 'void #:attrs '(("charset" . "UTF-8")))
```

<sub>Result</sub>

```HTML
<div id="sample-id"></div>
<textarea disabled></textarea>
<img src="https://example.com/cat.jpg"/>
<meta charset="UTF-8">
```

### Adding content to an element:

The `inner` argument can take a string or a list of child elements, but we'll
look at adding inner elements later. For now when the `inner` argument is given
a string, it will use it as the inner text. By default the given string will be 
escaped.

If you want to inject a raw string, you can do so using the `inner!` argument,
it only accepts a string and will not perform any escaping.

<sub>Guile</sub>

```scheme
(markup-el "div" #:inner "This is my inner text.")
(markup-el "div" #:inner "<span>Inner text that contains HTML will be escaped.</span>")
(markup-el "div" #:inner! "<span>Using inner! can be risky, take care, no escaping here.</span>")
```

<sub>Result</sub>

```HTML
<div>This is my inner text.</div>
<div>&lt;span&gt;Inner text that contains HTML will be escaped.&lt;/span&gt;</div>
<div><span>Using inner! can be risky, take care, no escaping here.</span></div>
```

### Adding child elements:

As stated earlier, the `inner` argument can also take a list of, lists of
arguments. These inner argument lists will be recursively applied to the
`markup-el` procedure. This means that each of the inner quoted list can contain
any of the arguments accepted by the `markup-el` method.

<sub>Guile</sub>

```scheme(
(markup-el "div" #:attrs '(("id" . "colors"))
           #:inner '(("div" #:inner "Red")
                     ("div" #:inner "Blue")
                     ("div" #:inner "Green")))
```

<sub>Result</sub>

```HTML
<div id="colors">
  <div>Red</div>
  <div>Blue</div>
  <div>Green</div>
</div>
```

### Creating multiple elements at once:

There's also a helper method available `markup-els` for situations where you
would like to create multiple elements at the root level, meaning, without being
wrapped in a parent node. This procedure has one required argument and that is a
list of argument lists. It also accepts a `lvl` argument at the end, that we'll
discuss next.

<sub>Guile</sub>

```scheme(
(markup-els
 '(("div" #:inner "A")
   ("div" #:inner "B")
   ("div" #:inner "C")
   ("div" #:inner "D")
   ("div" #:inner "E")))
```

<sub>Result</sub>

```HTML
<div>A</div>
<div>B</div>
<div>C</div>
<div>D</div>
<div>E</div>
```

### Controlling indentations

If you care about indentations, you'll be happy to know that you do have some
control over it. The first thing you can do is set the indentation size using
`set-indentation-size`. The default indentation size is `2`.

<sub>Guile</sub>
```scheme
(markup-el "div"
           #:inner '(("div" #:inner "Red")
                     ("div" #:inner "Blue")
                     ("div" #:inner "Green")))

;; Sets the global indentation size.
(set-indentation-size 4)

(markup-el "div"
           #:inner '(("div" #:inner "Red")
                     ("div" #:inner "Blue")
                     ("div" #:inner "Green")))
```

```html
<!-- Uses the default indentation size. -->
<div>
  <div>Red</div>
  <div>Blue</div>
  <div>Green</div>
</div>

<!-- This one uses our updated indentation size. -->
<div>
    <div>Red</div>
    <div>Blue</div>
    <div>Green</div>
</div>
```

In addition to the `set-indentation-size` helper, you can also specify the
indentation level of each element using the `#:lvl` argument. The level argument
allows you to shift an element and its children up or down. A level is basically 
this: `indentation-size * lvl`.

```scheme
(markup-el "div" #:lvl 5
           #:inner '(("div" #:inner "Red")
                     ("div" #:inner "Blue")
                     ("div" #:inner "Green")))
```

```html
<!-- Shifted up 5 times the indentation size. -->
          <div>
            <div>Red</div>
            <div>Blue</div>
            <div>Green</div>
          </div>
```

### HTML document example

Here's an example of a default HTML5 document's markup.

```scheme
(markup-els
  '(("!DOCTYPE" #:type 'void #:attrs ("html"))
    ("html" #:attrs (("lang" . "en"))
     #:inner
     (("head"
       #:inner (("meta" #:type 'void #:attrs (("charset" . "UTF-8")))
                ("meta" #:type 'sc #:attrs (("name" . "viewport")
                                            ("content" . "width=device-width, initial-scale=1.0")))
                ("title" #:inner "My Page Title")))
      ("body" #:inner "Hello World")))))
```

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Page Title</title>
  </head>
  <body>Hello World</body>
</html>
```
