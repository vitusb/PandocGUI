# PandocGUI

Graphic frontend for [pandoc](https://github.com/jgm/pandoc) (Universal markup converter by John MacFarlane). This is a tiny Zenity-script, using the Golang implementation of "[Zenity](https://github.com/ncruces/zenity)" scripting GUI by Nuno Cruces together with busybox-shell.

Info: Due to the very large size of "pandoc.exe" and the engines (provided here), you will not find them in this repo. Please look at the releases for a complete package with all needed files 😃 !

## Features
- Universal GUI-based document-converter based on "Pandoc".
- Basic conversion-tests were performed with testdocuments from the "German Federal Monitoring Center for Accessibility of Information Technology":
  - https://handreichungen.bfit-bund.de/bf-dokumente-lernkontext/formate/pdf/entscheidungshilfepdfkonverter.html
- German and English language-support.
- Simple and portable without installation.
- Works also with a regular installation under Windows by using the "Pandoc"-path under "%USERPROFILE%" as working-directory.
- Simple to migrate the scriptings to Unix/Linux because of using "busybox" and "zenity" in backend.
- Predefines CSS-Files for document-layouting.
- All errors from "Pandoc" are masked and shown to the user.
- Full "Unicode" support.
- Support for spaces in path-names and file-names.
- Supported PDF-engines: "wkhtmltopdf" and "weasyprint".
- Commandline-support for source-documents.
- Support for all documents, supported by "Pandoc".
- Unattended execution of "busybox" to hide console-output.

In order to test the conversion of some test-documents, you may
use test-documents from here:
- https://handreichungen.bfit-bund.de/bf-dokumente-lernkontext/
- https://handreichungen.bfit-bund.de/bf-dokumente-lernkontext/formate/pdf/entscheidungshilfepdfkonverter.html#testdokumente-zur-pr%C3%BCfung

Further readings: Matterhorn Protocoll.
- https://pdfa.org/resource/the-matterhorn-protocol/
Further readings: Is my PDF accessible ?
- https://pac.pdf-accessibility.org/de

The code is based on busybox-w32 (unicode version with "noconsole"):
- https://github.com/rmyorston/busybox-w32
- https://frippery.org/busybox/

... with modifications to work with the tiny "Zenity GoLang" version
"Zenity dialogs for Golang, Windows and macOS" from here:
- https://github.com/ncruces/zenity

## Background-Info:

- The code was modified to work under the Windows (x64) version of
  "busybox". Especially the message-boxes by powershell/vbs-code are
  coded, because of missing message-box coding under Windows BEFORE
  ZENITY WILL BE AVAILABLE FOR EXECUTION; the Zenity-core may be
  simply adapted to Zenity under Unix in order to migrate this stuff
  to Linux, etc. This script works with "Unicode" and "spaces" in
  path- and file-names.

- The used "pdf-backend-engine" for "Pandoc" relies on "wkhtmltopdf"
  because of its simplicity:
  - https://wkhtmltopdf.org/downloads.html
  - https://github.com/wkhtmltopdf/wkhtmltopdf
- ... but pay attention:
  - https://github.com/jgm/pandoc/issues/10142#issue-2501282985
  It seems that "wkhtmltopdf" has been deprecated (the underlying
  engine is ancient). We should change the default --pdf-engine for
  HTML to "pagedjs-cli" or "weasyprint". Consensus is that
  "weasyprint" is lighter weight and easier to install, so it's
  probably a better default:
  - https://weasyprint.org/
  - https://github.com/Kozea/WeasyPrint

  Possible drawbacks:
  breaking existing workflows that rely on "wkhtmltopdf".

  "wkhtmltopdf" has only one executable WITHOUT lots of external dependencies. The "CSS" for its usage comes with little mods from:
  - https://gist.github.com/killercup/5917178
  "wkhtmltopdf" is still used here, because of its performance and the ability to work with some graphics in Word-Documents. "weasyprint" is a python-program and much slower and it was impossible to get the graphics from Word-Docs into the PDFs by "weasyprint". "EMF"-images are still a problem ...

## DEBUGGING / VERBOSITY / Language-Selection

To run this stuff unattended in <b>German</b> language, use:
```
busybox.exe bash -o noiconify -o noconsole pandoc_de.sh
```

For debugging, you may use only the script as a parameter:
```
busybox.exe bash pandoc_de.sh
```

To run this stuff unattended in <b>English</b> language, use:
```
busybox.exe bash -o noiconify -o noconsole pandoc_en.sh
```

For debugging, you may use only the script as a parameter:
```
busybox.exe bash pandoc_en.sh
```

