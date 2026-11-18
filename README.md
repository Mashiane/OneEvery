# OneEvery

**OneEvery is a B4J desktop application for designing, composing, previewing and publishing multi-page HTML websites.**

It provides a visual authoring environment backed by SQLite, a reusable catalogue of HTML elements and framework metadata, an interactive command interface, and a static HTML generation pipeline. Its editor is implemented in **B4J using JavaFX**. Websites created with it are written to local folders as HTML, CSS, JavaScript and related assets.

This repository contains the B4J project, application modules, visual designer layouts, bundled web resources, SQLite databases, distribution archives and a user manual.

> **Project status and scope:** This README describes the implementation found in the repository. It is not a claim that every screen or helper is complete. Some areas are scaffolding or have incomplete handlers; build dependencies also include shared B4J modules that are not all included in this repository.

## Contents

- [What OneEvery does](#what-oneevery-does)
- [Architecture at a glance](#architecture-at-a-glance)
- [The two database layers](#the-two-database-layers)
- [How a website is created](#how-a-website-is-created)
- [How elements are modelled and rendered](#how-elements-are-modelled-and-rendered)
- [How publishing works](#how-publishing-works)
- [The command interface](#the-command-interface)
- [Creator catalogue and framework support](#creator-catalogue-and-framework-support)
- [HTML playground and JavaScript transpiler](#html-playground-and-javascript-transpiler)
- [Repository layout](#repository-layout)
- [Technology and dependencies](#technology-and-dependencies)
- [Building and running the source](#building-and-running-the-source)
- [Important implementation details and limitations](#important-implementation-details-and-limitations)
- [Further reading](#further-reading)

## What OneEvery does

OneEvery is intended to make the construction of conventional HTML websites manageable from a desktop IDE-like environment. Instead of writing an entire page as a single HTML string, a developer can define elements, configure their properties, arrange them into parent/child structures, and let OneEvery generate the markup.

The application brings together several related activities:

1. **Project management** – create or open a website project and maintain its metadata.
2. **Page management** – create, rename, activate, edit and remove pages. The `index` page is protected from deletion.
3. **Element composition** – create HTML elements, assign unique identifiers, set their text and values, and arrange them in a hierarchy.
4. **Attribute management** – add arbitrary HTML attributes to an element, with stored default values.
5. **CSS class management** – attach framework classes to elements from the shared framework class catalogue.
6. **CSS metadata and styles** – define reusable style metadata for the Creator catalogue and preview elements with CSS rules.
7. **Live preview** – render the current element or page in the application's JavaFX WebView and inspect the generated HTML.
8. **Command-driven editing** – execute commands for common project, page and element operations.
9. **Reusable definitions and macros** – maintain element definitions and turn common element structures or class combinations into reusable command macros.
10. **Static output** – generate page files and copy the selected local CSS/JavaScript resources into a project's website output directory.

The output is a set of files that can be opened locally or deployed to a conventional static web host. The source code does not implement a hosted website runtime or a mandatory application server.

## Architecture at a glance

The main data flow is:

```text
                    OneEvery desktop application
                         B4J / JavaFX
                               |
             +-----------------+------------------+
             |                 |                  |
        Visual editor      Command interface   HTML playground
             |                 |                  |
             +-----------------+------------------+
                               |
                     Main application logic
                         OneEvery.b4j
                               |
             +-----------------+------------------+
             |                                    |
       Creator catalogue                    Active website
         creator.db                         <AppName>.db
             |                                    |
   Frameworks, tags, elements,            Pages, Components,
   attributes, classes, CSS,              Attributes, Classes,
   templates, macros                       CSS/JS file records
             |                                    |
             +-----------------+------------------+
                               |
                       HTML generation
                   HTMLElement / HTMLPage
                               |
                     Projects/<AppName>/www
                               |
                   HTML pages + CSS + JS + assets
                               |
                    WebView / external browser
```

The responsibilities are deliberately separated:

- The **desktop UI** presents the project tree, editable property bags, code editor, WebView preview and command input.
- **OneEvery.b4j** contains the primary application logic, including the JavaFX application startup, editor screens, Creator operations, HTML rendering and page generation.
- **CLI.bas** implements the command interpreter and performs project/page/component operations against the active project's database.
- **creator.db** is the reusable catalogue. It describes what an element can be and the attributes/classes associated with its definition.
- A project's **SQLite database** stores the actual instances used by that website.
- **HTMLApp** and **HTMLPage** prepare the output folders and generate HTML documents.

A further small database, **oneevery.db**, is used by the application's key/value storage helper to retain settings such as the last active project and editor state. It is not the same thing as either the Creator database or a website project database.

## The two database layers

Understanding this separation is essential when working on OneEvery or extending it.

### 1. Creator database – creator.db

The Creator database is opened from the application's working directory and prepared by `Creator_Prepare` in `OneEvery.b4j`.

It contains reusable definitions rather than the elements belonging to one particular website. It can be thought of as the application-wide catalogue from which website content is assembled.

The principal tables include:

| Table | Purpose |
|---|---|
| `Frameworks` | Framework names and their abbreviations. |
| `Tags` | Recognised HTML tag names used when validating element types. |
| `Categories` | Categories used to organise Creator elements. |
| `Elements` | Reusable element definitions, including tag type, framework, category, text, parent and ordering information. |
| `Attributes` | Attribute definitions attached to Creator elements, including default values, field types, file flags and validation metadata. |
| `Classes` | CSS/framework class definitions attached to Creator elements. |
| `FrameworkClasses` | The catalogue of available framework class names, their display names, categories and framework-specific keys. |
| `CSS` | Style declarations associated with Creator elements, including whether a rule is page-level or element-level. |
| `Templates` | Reusable tag/template definitions for a framework. |
| `TemplatesAttributes` | Attribute definitions associated with a template. |
| `TemplatesClasses` | Class definitions associated with a template. |
| `Imports` | Intermediate records used when importing an HTML structure into the Creator model. |
| `Devices` | Device/class-size descriptions used by the style-definition interface. |
| `Macros` | Saved command sequences, argument placeholders and descriptions. |
| `Logs` | Command execution history with timestamps. |

Several records use composite textual keys to identify their relationship. For example:

- A framework class key is formed from the framework and class name: `Framework.ClassName`.
- An element attribute key is based on its element record ID and attribute name: `ElementID.AttributeName`.
- An element class key is based on its element record ID and class name.

The application uses these keys to find and update related records.

The Creator UI exposes these records through grids and property bags. The Elements screen, for example, has separate tabs for the element itself, its attributes, its styles/classes and its CSS settings. Selecting an element loads its related records and renders a preview.

### 2. Website project database – <AppName>.db

Every website project has its own SQLite database, stored under:

```text
Projects/
  <AppName>/
    <AppName>.db
```

The schema is prepared by `CLI.AppSQL_Prepare` in `CLI.bas`.

| Table | Purpose |
|---|---|
| `App` | The project record. The application stores its metadata as JSON in the `properties` field, using record ID `1`. |
| `Pages` | Page name, title, description, keywords, output filename, active state and ordering. |
| `Components` | Actual HTML element instances belonging to pages. Stores tag type, element identifier, text, value, name, active state, parent ID and ordering. |
| `Attributes` | HTML attributes attached to project components. |
| `Classes` | CSS/framework classes attached to project components. |
| `CSSFiles` | CSS resources selected for the website, including framework, active state and order. |
| `JSFiles` | JavaScript resources selected for the website, including framework, active state and order. |

The project database does not need to duplicate the entire Creator catalogue. It stores the website's actual component records and their configured properties. During editing, the application consults the Creator database to validate tag names and class names.

### 3. Application state – oneevery.db

At startup, OneEvery initialises its key/value store through:

```basic
jMash.Initializekvs(File.DirApp, "oneevery.db")
```

The application stores values such as the last project map, active page, active element, editor content and JavaScript playground content. This supports restoring the previous working context when the application starts again.

## How a website is created

### Step 1 – Create a project

Choose **App → New** in the project tree to open the project property interface.

The project metadata includes:

- App name
- Site title
- App ID
- Framework
- Version
- Author
- Website
- Email
- Copyright information
- Whether Font Awesome should be included

The command interface also exposes project creation:

```text
create appName appID appTitle
```

For example:

```text
create MySite com.example.mysite MySite
```

The command parser is whitespace-based, so keep the three command arguments to single tokens when using this form. The graphical property interface is preferable for editing more detailed project metadata.

When a project is created, OneEvery:

1. Sets the project metadata, with Bootstrap as the initial framework.
2. Creates `Projects/<AppName>`.
3. Creates the `www`, `www/js`, `www/css`, `www/fonts` and `www/img` folders.
4. Creates the project's SQLite database.
5. Prepares the project tables.
6. Saves the project metadata JSON in the `App` table.
7. Creates the initial `index` page.
8. Adds the default Bootstrap CSS and JavaScript file records.
9. Creates a `Code` directory for generated code-related files.

The defaults in `CLI.Initialize` include Bootstrap CSS and the following JavaScript files:

```text
jquery-3.2.1.min.js
popper.min.js
tether.min.js
bootstrap.min.js
```

These are initial project asset records; the actual files must be available in the application's resource folders when the project is prepared for publishing.

### Step 2 – Open an existing project

Use **App → Open** to select a project `.db` file. OneEvery opens the database, ensures the project tables are present, reads the `App` record and restores the project metadata.

The command interface provides:

```text
cd MySite
```

The project is loaded from the application's `Projects` directory. A project folder and its corresponding database must exist.

### Step 3 – Create and manage pages

A newly created website starts with an `index` page. Additional pages can be created through the Pages screen or with:

```text
add_page about About
```

The page name is normalised to lowercase by the command implementation. The page record contains the title, description, keywords, active state, tab order and HTML filename. The generated output filename is based on the page name:

```text
about.html
```

Useful page commands are:

| Command | Behaviour |
|---|---|
| `list_pages` | Lists the project's pages. |
| `add_page pageName pageTitle` | Creates a page. |
| `active_page pageName` | Selects the active page for editing. |
| `active_page ?` | Reports the currently active page. |
| `rename_page oldName newName` | Renames a page. |
| `delete_page pageName` | Deletes a page, except `index`. |
| `serve_page pageName` | Builds and opens one page. |
| `serve appName` | Builds the active project pages and opens the website. |

The graphical Pages interface also supports editing page metadata and active state. Pages marked inactive are skipped by the all-pages publishing routine.

### Step 4 – Add HTML elements

Elements are stored in the project's `Components` table. Each element belongs to a page and is identified by an element name. Its key takes the form:

```text
pageName.elementName
```

The element's `ParentID` defines its position in the component hierarchy. A value of `0` identifies a top-level element.

The general command is:

```text
add_element tagName elementID
```

For example:

```text
active_page index
add_element div main
add_element h1 heading
set_text heading Welcome
set_parent heading main
```

The tag must be present in the Creator database's `Tags` table. The command creates a component with an active state, ordering value, default text and no parent, then refreshes the page preview.

There are convenience commands for common HTML tags and form controls. Examples include:

```text
add_div content
add_ul navigation
add_li homeItem
add_anchor logo https://example.com
add_text emailInput
add_email emailAddress
add_password passwordInput
add_checkbox rememberMe
add_radio choice
add_select country
add_textarea message
add_button submitButton
```

The input helpers create an HTML `input` or other appropriate tag and set its `type` or related default attributes. The exact command set is defined in the `help` branch of `CLI.ExecuteCommand`.

### Step 5 – Set properties, attributes and classes

Element properties such as text, value, tag type, name, active state and tab order can be changed with `update_element` or its `set_*` aliases.

For example:

```text
set_text heading Welcome to OneEvery
set_name emailInput email
set_value emailInput user@example.com
set_placeholder emailInput Your email address
set_required emailInput
```

Arbitrary attributes are stored separately from the main component record:

```text
add_attribute emailInput autocomplete email
delete_attribute emailInput autocomplete
list_attributes emailInput
```

CSS classes are stored in the project's `Classes` table and validated against the shared `FrameworkClasses` catalogue:

```text
add_class main container
add_class submitButton btn
add_class submitButton btn-primary
delete_class submitButton btn-primary
list_classes submitButton
```

A class is not simply accepted as any string by the CLI. The implementation checks that the class exists in the Creator database for the configured framework.

### Step 6 – Arrange the element hierarchy

The parent/child relationship is the basis of HTML nesting. For example, a heading and a paragraph may both be children of a content container.

```text
add_div content
add_element h2 pageHeading
add_element p introduction
set_parent pageHeading content
set_parent introduction content
```

The page generator selects active elements whose `ParentID` is `0`, ordered by `TabIndex`. The component builder then recursively loads each active child, also ordered by `TabIndex`, and appends it to the parent.

The visual editor provides controls for editing the element records and related attributes/classes; the CLI provides direct operations for the same project model.

### Step 7 – Preview the page

Changing the active page or executing operations that affect its components calls the page preview flow. OneEvery builds the selected page, loads the resulting local HTML file into a JavaFX WebView and can display the formatted HTML source in the HTML view.

This is a local rendering preview of generated files, not a remote hosted preview service.

## How elements are modelled and rendered

There are two related but distinct element models.

### Creator element definitions

A Creator element is a reusable definition stored in `creator.db`. Its properties include:

- HTML element/tag type
- Element identifier and display name
- Framework and category
- Default text and value
- Parent element ID and tab order
- Active state
- Text placement behaviour
- Optional wrapper tag
- Global HTML options such as contenteditable, draggable, spellcheck and hidden

Its attributes, classes and CSS definitions are stored in related tables keyed by the Creator element ID.

The Creator preview builder is `Elements_Build(id)`. It reads the selected definition, constructs an `HTMLElement`, applies active attributes, classes and CSS properties, recursively renders active children, and optionally wraps the result in a configured wrapper element.

### Project component instances

A project component is an actual instance stored in the website's own `Components`, `Attributes` and `Classes` tables.

The project renderer is `Components_Build(id)`. It:

1. Reads the component's tag, element identifier, text, value, name and text-after flag.
2. Creates an `HTMLElement`.
3. Applies that instance's active attributes.
4. Applies its active classes.
5. Retrieves active child components ordered by tab index.
6. Recursively renders the child components.
7. Returns the resulting HTML.

The page builder uses the project renderer, not the Creator renderer. This separation lets Creator definitions be maintained independently of each site's content.

### Attributes and file-valued properties

Attributes have a name and stored default value. The Creator schema additionally records field type, whether a value represents a file, whether the field is fixed/active/required, descriptions and optional lists/ranges.

When Creator attributes are applied, the renderer checks the file flag. Local file values can be converted to a file URL relative to the current website output directory; values that already begin with `http` are treated as external URLs.

### CSS and framework classes

Framework classes and custom style metadata are represented separately:

- **Classes** are CSS class names assigned to elements.
- **FrameworkClasses** is the catalogue used to validate and describe those names.
- **CSS** stores property/value style information associated with Creator elements.

Creator CSS records can be marked as element-level or page-level using `OnPage`. The Creator renderer applies element-level styles to the preview element and page-level styles to the page's style element through `Style_Add`.

OneEvery also has a style-definition workflow that generates class names from a prefix and a list of suffixes, then stores those classes in `FrameworkClasses`. This can be used to build framework class enumerations and related macros.

## How publishing works

Publishing is implemented as a local static-site build.

The central flow is:

```text
App_Publish
  |
  +-- App_Check
  +-- App_OpenDB
  +-- App_PreparePublish
  |     |
  |     +-- Read project metadata
  |     +-- Initialise the HTMLApp output folders
  |     +-- Extract bundled web resources into www
  |     +-- Copy active CSS resources into www/css
  |     +-- Copy active JS resources into www/js
  |     +-- Add Font Awesome when enabled
  |
  +-- App_Pages
  |     |
  |     +-- Select active Pages
  |     +-- Page_Build for each page
  |            |
  |            +-- Read page metadata
  |            +-- Find active root components
  |            +-- Components_Build recursively
  |            +-- HTMLPage.Build
  |
  +-- HTMLApp.Open
        |
        +-- Open generated www/index.html externally
```

### Output directory

The generated project is written under:

```text
Projects/
  MySite/
    MySite.db
    Code/
    www/
      index.html
      about.html
      css/
      js/
      fonts/
      img/
```

The actual files depend on the pages and resources configured for the project.

### Asset preparation

`App_PreparePublish` reads the project metadata and initializes the `HTMLApp` object. It copies the bundled `resources.zip` into the website's `www` directory, extracts it, and deletes the temporary ZIP after extraction.

It then reads active records from the project's `CSSFiles` and `JSFiles` tables, copies the corresponding files from the application's local `css` and `js` directories into the project's output folders, and registers them with `HTMLApp` so that generated pages can reference them.

Font Awesome is added when the project's `UseFontAwesome` setting is enabled.

The CSS/JS file selection screens copy a picked local file into the application's shared `css` or `js` resource directory and save the filename in the project database. The project can therefore select and order the resources that will be included when its output is prepared.

### HTML document generation

`HTMLPage` constructs each output document. It creates the document structure, title, metadata, CSS links, style element and JavaScript script references. Its metadata includes viewport and character encoding information, author, email, website, application version, copyright, description, keywords and a generator identifier.

CSS and JavaScript references are generated as local file URLs for the output directory. The current implementation is designed around locally generated files and is best understood as a desktop authoring/publishing workflow.

### Opening the output

`HTMLApp.Open` uses `AWTRobot.SystemOpenExternalFile` to open the generated `index.html` file with the operating system's associated application. `OpenPage` does the same for an individual page.

The output itself is ordinary HTML and assets. It can be inspected, copied, versioned or deployed independently of the OneEvery desktop application.

## The command interface

The command interface is a command interpreter embedded in the desktop application. It is not a separately packaged shell executable.

Commands are entered in the CLI screen. `CLI.ExecuteCommand` validates and dispatches them, records the command in the Creator database's `Logs` table, performs the relevant operation and collects status/output messages in the `Commands` list.

Run:

```text
help
```

to list the commands recognised by the current implementation.

### Common command reference

| Area | Command | Description |
|---|---|---|
| Project | `create appName appID appTitle` | Create a project with initial Bootstrap defaults. |
| Project | `cd appName` | Open an existing project from the Projects directory. |
| Project | `serve appName` | Build active pages and open the generated website. |
| Page | `add_page pageName pageTitle` | Add a page. |
| Page | `list_pages` | List pages. |
| Page | `active_page pageName` | Select the active page. |
| Page | `active_page ?` | Report the active page. |
| Page | `rename_page oldName newName` | Rename a page. |
| Page | `delete_page pageName` | Delete a page other than index. |
| Page | `serve_page pageName` | Build and open one page. |
| Element | `add_element tag elementID` | Add an HTML element. |
| Element | `add_div elementID` | Add a div. |
| Element | `add_child childID parentID` | Add a child div and assign its parent. |
| Element | `list_elements` | List project components. |
| Element | `select_element elementID` | Set an element as active/selected. |
| Element | `update_element elementID property value` | Update a supported component property. |
| Element | `rename_element oldID newID` | Rename a component identifier. |
| Element | `copy_element sourceID targetID` | Copy an element record and associated properties. |
| Element | `delete_element elementID` | Delete an element. |
| Hierarchy | `set_parent childID parentID` | Assign an element's parent. |
| Attribute | `add_attribute elementID name value` | Add or update an attribute. |
| Attribute | `delete_attribute elementID name` | Remove an attribute. |
| Attribute | `list_attributes elementID` | List an element's attributes. |
| Class | `add_class elementID className` | Attach a known framework class. |
| Class | `delete_class elementID className` | Remove a class. |
| Class | `list_classes elementID` | List an element's classes. |
| Framework | `add_styleclass className category` | Add/update a framework class catalogue entry. |

A number of aliases are accepted (for example, underscore-free command names and some component terminology). The authoritative list and validation rules are in `CLI.ExecuteCommand`; the table above is a practical summary, not an exhaustive grammar specification.

### Command parsing considerations

The parser splits commands on spaces and several handlers expect a fixed number of tokens. Some commands use the remaining text as a value, but commands such as `create` and `add_page` have stricter token counts. Avoid relying on shell-style quoting or multi-word values in every command. Use the project/page property interfaces for values that need more flexible editing.

Commands that operate on elements depend on the active page. Select the page before issuing element operations.

## Creator catalogue and framework support

The Creator section of the application maintains the reusable vocabulary used by the editor.

The navigation tree exposes areas for:

- Frameworks
- Devices
- Categories
- Tags
- Styles
- Elements
- Attributes
- Templates
- Playground

The framework records contain a framework name and abbreviation. Framework class records contain the actual class string, a display name, a category and an active flag. Categories help group class families in the user interface.

### Defining style class families

The Styles interface includes a class-definition property bag. It accepts a prefix, prefix description, comma-separated suffixes, framework and category.

For example, a prefix such as `btn` and suffixes such as `primary,secondary` can create class names such as `btn-primary` and `btn-secondary`. The generated records are saved in `FrameworkClasses`.

A class must be registered in the catalogue before the project CLI's `add_class` command will accept it.

### Templates

Templates are a layer derived from captured Creator elements. The `Templates_Execute` workflow can rebuild the template tables from the existing Elements, Attributes and Classes records. It groups template definitions by framework and tag instance and associates the corresponding attributes and classes.

The template editor displays a template's attributes and classes when its row is selected. This is a metadata and authoring facility; it should not be confused with a full templating language or a runtime component framework.

### Importing HTML structures

The Playground includes code for tidying HTML, parsing its structure and saving an intermediate representation in the `Imports` table. The import workflow then creates Creator element records, captures attributes and classes, and reconstructs parent relationships from the recorded placements.

This workflow helps convert an existing HTML structure into the Creator's element model. The implementation relies on the HTML tidy/parser support configured by the B4J project.

## HTML playground and JavaScript transpiler

### HTML playground

The Playground screen accepts HTML source, previews it in the WebView and displays a structural tree. The editor also includes an import-structure path that can turn parsed markup into Creator records.

The playground and the page designer serve different purposes:

- The playground works with entered HTML source.
- The Creator designer works with reusable element definitions.
- The project editor works with component instances belonging to a website page.

### JavaScript transpiler

The JavaScript screen uses the `JQuery` class (the class name is historical; the source implements a small token transpiler).

It reads input line by line and replaces recognised pseudo-JavaScript tokens with JavaScript syntax exposed by the `HTMLElement` helper. Recognised tokens include:

```text
JSEqualTo
JSNotEqualTo
JSGreaterThan
JSLessThan
JSMultiply
JSAdd
JSGreaterOrEqualTo
JSLessOrEqualTo
JSIsEqualTo
JSBreak
JSContinue
JSSub
JSIf
JSThen
JSEndIf
JSDo
JSWhile
JSNL
JSElse
JSEndElse
JSReturn
JSEndSub
```

Lines that are not recognised tokens pass through as entered. The UI stores the last editor text and updates the transpiled output as the input changes.

This is a lightweight text transformation utility, not a general-purpose JavaScript compiler or parser.

## Repository layout

The repository contains application code, B4J visual designer layouts, database files, bundled libraries/resources and documentation.

| Path | Role |
|---|---|
| `OneEvery.b4j` | Main B4J project file and primary application implementation. It contains startup, JavaFX UI logic, Creator management, element rendering, page building and publishing. |
| `OneEvery.b4j.meta` | B4J IDE metadata such as navigation/bookmark/breakpoint state. |
| `CLI.bas` | Command interpreter, project database schema and project/page/component operations. |
| `HTMLApp.bas` | Website output directory management, CSS/JS registration and opening generated files. |
| `HTMLPage.bas` | HTML document/head/body creation, metadata, CSS links and JavaScript references. |
| `JQuery.bas` | Line-oriented pseudo-JavaScript token transpiler. |
| `OEContainer.bas` | Early container helper class based on an `HTMLElement` div. |
| `OENavBar.bas` | Bootstrap navbar helper/example with fixed Home/About/Contact links and optional search. |
| `frmMacros.bas` | Macro editor/management screen logic. |
| `modOneEvery.bas` | Shared OneEvery module state, including the available database type list. |
| `modApp.bas` | Application module placeholder. |
| `Files/` | B4J visual designer layouts, including the main screen, project tree, editor, CLI and property views. |
| `Objects/` | Project resources and generated/project-specific objects, including framework code. |
| `Projects/` | Project workspace/resources checked into the repository. New projects are created here at runtime. |
| `creator.db` | Creator catalogue SQLite database distributed with the repository. |
| `oneevery.db` | Application key/value state database. |
| `css/`, `js/`, `img/` | Application-side web resources used when preparing project output. |
| `codemirror-5.33.0/` | Bundled CodeMirror editor resources. |
| `jquery.mobile-1.4.5/` | Bundled jQuery Mobile resources. |
| `material-components-web.min.css/js` | Bundled Material Components for the Web resources. |
| `w3.css`, `w3mobile.css`, `w3pro.css` | Additional bundled W3.CSS resources. |
| `Manual/` | User manual, screenshots and supporting documentation. |
| `OneEvery.pdf`, `OneEvery.zip`, `OneEvery.7z`, `OneEvery.jar` | Existing PDF, archive and compiled distribution artifacts. |

The repository also contains bundled assets that are not part of the core B4J source modules. Their presence does not imply that every asset is selected for every generated website.

## Technology and dependencies

### Application technology

- **B4J** – application language and project environment.
- **JavaFX** – desktop forms, split panes, tree views, tabs and WebView-based preview.
- **SQLite** – the Creator database, per-project databases and persistent application state.
- **HTML/CSS/JavaScript** – the generated website output.
- **HTMLElement** – a shared helper module used to compose HTML and expose HTML/JavaScript operations.
- **jMash and DBUtils** – shared helpers for key/value storage, string/list/JSON operations and database access.
- **AWTRobot** – used by `HTMLApp` to open generated files externally.
- **Archiver** – used to unpack the project's bundled web resources.

### B4J libraries declared in OneEvery.b4j

The project file declares a number of B4J libraries, including:

```text
archiver
byteconverter
cssutils
javaobject
jcontrolsfx
jcore
jcustomtoast
jdateutils
jfx
jnet
jokhttputils2
jpdfjet
jpoi
jrandomaccessfile
jreflection
jrldialogsx
jserver
jshell
json
jsql
jstringutils
jtidy
jxmlsax
jxui
mashpoi
mashpropertybag
xml2map
xmlbuilder
jawtrobot
```

It also declares additional JARs for SQLite JDBC, RichTextFX, FontAwesome and Material Icons. The exact versions and local library availability should be checked in the B4J project configuration and the developer's B4J installation.

### Shared source modules

The project file references shared modules outside this repository, including modules for:

- Badger
- clsCodeModule
- clsKVS
- CodeArea
- CustomListView
- DBUtils
- HTMLElement
- jMash
- TabStopManager
- TextFlow
- Utils

Some module references in the checked-in B4J project file use absolute Windows paths such as `C:\b4j\shared\...`; another uses a relative path. These dependencies are not all vendored into this repository. A developer setting up the source on another machine will need to obtain the corresponding modules and relink them in B4J.

## Building and running the source

The source is a B4J desktop project, not a Node/npm project and not a conventional web application with a package manager.

### Prerequisites

1. A working B4J installation compatible with the checked-in project.
2. A Java runtime supported by that B4J installation.
3. The B4J libraries declared in `OneEvery.b4j`.
4. The external/shared B4J modules referenced by the project file.
5. The bundled project resources and application-side CSS/JavaScript assets.

### Opening the project

1. Clone or download this repository.
2. Open `OneEvery.b4j` in the B4J IDE.
3. Inspect the project library declarations and module paths.
4. Resolve the shared module references for the local development machine. In particular, update machine-specific absolute paths such as `C:\b4j\shared\...`.
5. Confirm that the SQLite JDBC and other additional JAR dependencies are available to the project.
6. Compile and run from the B4J IDE.

The repository includes a compiled JAR and archive files, but this README does not assume that those artifacts are a reproducible build pipeline. There is no package-manager lockfile or complete portable dependency manifest in the repository. A clean build should therefore be verified in the target B4J environment rather than inferred from the presence of the compiled artifact.

### First use

On startup, OneEvery initialises the Creator database schema, creates its workspace folders and restores the last project if a valid last-project setting is present. Create a new website through **App → New**, save its details, then use the Pages and CLI screens to construct content. Use **App → Publish** to generate the website files.

## Important implementation details and limitations

The following details are worth knowing when extending or maintaining the code.

1. **Static website output.** The publishing flow generates local HTML documents and copies CSS/JavaScript assets. It does not implement a hosted website service or automatically deploy to a hosting provider.
2. **Main implementation is concentrated in OneEvery.b4j.** A considerable amount of the application logic lives in the main B4J project source rather than in separate classes.
3. **Creator and project renderers differ.** `Elements_Build` renders Creator definitions from `creator.db`; `Components_Build` renders website component instances from the active project database. Changes to one path do not automatically change the other.
4. **The project renderer's CSS path is limited.** The project `Components_Build` applies active attributes and classes and recursively renders children. The call that would apply the Creator CSS table is not active in that method. The dedicated CSS/style rendering routines are used in Creator preview paths.
5. **HTMLApp.Build is a stub.** The class contains a placeholder `Build` method; the actual page-building and publishing orchestration is performed by the main application module.
6. **Some helper classes are early implementations.** For example, `OEContainer.HTML` is empty in the checked-in source and `OENavBar` is a small Bootstrap-specific helper rather than a complete navigation system.
7. **The command grammar is intentionally simple.** Commands are split on whitespace and several handlers require specific token counts. Multi-word strings and quote escaping are not consistently handled across commands.
8. **The database schema is created in code.** `Creator_Prepare` and `CLI.AppSQL_Prepare` define tables using DBUtils. There is no separate SQL migration directory or formal schema-versioning mechanism visible in the repository.
9. **Project file paths are Windows-oriented.** Directory construction uses backslashes and the project includes absolute Windows module references. Portability to other operating systems requires path and dependency review.
10. **External dependencies are material.** Core modules such as `HTMLElement`, `jMash`, `DBUtils` and the custom UI controls are shared dependencies; they are not all present as standalone source files in this repository.
11. **Some CRUD callbacks are placeholders.** A few UI event handlers are empty or have only partial logic. Treat the source as the authoritative statement of what is currently implemented.
12. **The CLI protects the index page.** `Delete_Page` explicitly prevents deleting the page named `index`.
13. **Asset files must be present locally.** Project asset rows point to files in the application's `css` and `js` directories. Registering a filename in the database alone does not create the file.
14. **No automated test suite or CI workflow is evident in the repository tree.** The B4J project should be built and its create/edit/preview/publish flows tested in the target environment.

These are implementation observations, not necessarily design decisions. They are useful starting points for anyone considering maintenance, refactoring or future feature work.

## Further reading

- [OneEvery B4J project and main application source](OneEvery.b4j)
- [Command interpreter and project database logic](CLI.bas)
- [HTML application/output folder helper](HTMLApp.bas)
- [HTML document builder](HTMLPage.bas)
- [JavaScript token transpiler](JQuery.bas)
- [Macro editor](frmMacros.bas)
- [User manual PDF](Manual/OneEvery.pdf)
- [Manual screenshots and supporting files](Manual/)
- [Bundled project resources](Files/)

## License and third-party resources

No root-level `LICENSE` file was present in the repository tree when this README was prepared. Do not assume that the repository or all bundled resources are available under an open-source license. Before redistributing the application or its bundled libraries, fonts, CSS, JavaScript and other third-party assets, verify the applicable upstream licenses and add the intended project license.

---

**OneEvery**  
B4J desktop website authoring and static HTML generation environment.
