#!bash

# --- PandocGUI (english) ---
#
# Tiny Zenity-Script v1.4 as frontend for "ZENITY" scripting GUI.
# By Veit Berwig ZIT-SH in 20250117
#
# - Universal GUI-based document-converter based on "Pandoc".
# - Basic conversion-tests were performed with testdocuments from the
#   "German Federal Monitoring Center for Accessibility of
#   Information Technology":
#   https://handreichungen.bfit-bund.de/bf-dokumente-lernkontext/formate/pdf/entscheidungshilfepdfkonverter.html
# - German and English language-support.
# - Simple and portable without installation.
# - Works also with a regular installation under Windows by using
#   the "Pandoc"-path under "%USERPROFILE%" as working-directory.
# - Simply to migrate to Unix/Linux because of using "busybox" and
#   "zenity" in backend.
# - Predefines CSS-Files for document-layouting.
# - All errors from "Pandoc" are masked and shown to the user.
# - Full "Unicode" support.
# - Support for spaces in path-names and file-names.
# - Supported PDF-engines: "wkhtmltopdf" and "weasyprint".
# - Commandline-support for source-documents.
# - Support for all documents, supported by "Pandoc".
# - Unattended execution of "busybox" to hide console-output.
#
# In order to test the conversion of some test-documents, you may
# use test-documents from here:
# https://handreichungen.bfit-bund.de/bf-dokumente-lernkontext/
# https://handreichungen.bfit-bund.de/bf-dokumente-lernkontext/formate/pdf/entscheidungshilfepdfkonverter.html#testdokumente-zur-pr%C3%BCfung
#
# Further readings: Matterhorn Protocoll.
# - https://pdfa.org/resource/the-matterhorn-protocol/
# Further readings: Is my PDF accessible ?
# - https://pac.pdf-accessibility.org/de
#
# The code is based on busybox-w32 (unicode version with "noconsole"):
# https://github.com/rmyorston/busybox-w32
# https://frippery.org/busybox/
#
# ... with modifications to work with the tiny "Zenity GoLang" version
# "Zenity dialogs for Golang, Windows and macOS" from here:
# https://github.com/ncruces/zenity
#
# Background-Info:
# ################
# - The code was modified to work under the Windows (x64) version of
#   "busybox". Especially the message-boxes by powershell/vbs-code are
#   coded, because of missing message-box coding under Windows BEFORE
#   ZENITY WILL BE AVAILABLE FOR EXECUTION; the Zenity-core may be
#   simply adapted to Zenity under Unix in order to migrate this stuff
#   to Linux, etc. This script works with "Unicode" and "spaces" in
#   path- and file-names.
#
# - The used "pdf-backend-engine" for "Pandoc" relies on "wkhtmltopdf"
#   because of its simplicity:
#   https://wkhtmltopdf.org/downloads.html
#   https://github.com/wkhtmltopdf/wkhtmltopdf
# - ... but pay attention:
#   https://github.com/jgm/pandoc/issues/10142#issue-2501282985
#   It seems that "wkhtmltopdf" has been deprecated (the underlying
#   engine is ancient). We should change the default --pdf-engine for
#   HTML to "pagedjs-cli" or "weasyprint". Consensus is that
#   "weasyprint" is lighter weight and easier to install, so it's
#   probably a better default:
#   https://weasyprint.org/
#   https://github.com/Kozea/WeasyPrint
#
#   Possible drawbacks:
#   breaking existing workflows that rely on "wkhtmltopdf".
#
#   "wkhtmltopdf" has only one executable WITHOUT lots of external
#   dependencies. The "CSS" for its usage comes with little mods from:
#   https://gist.github.com/killercup/5917178
#   "wkhtmltopdf" is still used here, because of its performance and
#   the ability to work with some graphics in Word-Documents.
#   "weasyprint" is a python-program and much slower and it was
#   impossible to get the graphics from Word-Docs into the PDFs by
#   "weasyprint". "EMF"-images are still a problem ...
#
# DEBUGGING / VERBOSITY
# #####################
# To run this stuff unattended, use:
# busybox.exe bash -o noiconify -o noconsole pandoc_en.sh
#
# For debugging, you may use only the script as a parameter:
# busybox.exe bash pandoc_en.sh
#
# For full script-output, use debug:
# set -x

# ####################################################################
# Message-Box WITH TIMEOUT ONE-LINER by POWERSHELL FOR SITUATIONS
# ####################################################################
# https://msdn.microsoft.com/en-us/library/x83z1d9f(v=vs.84).aspx
# https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/x83z1d9f(v=vs.84)
# ####################################################################
# PARAMETERS:
# intButton = object.Popup(strText,[nSecondsToWait],[strTitle],[nType]) 
# nType Parameter (in the form of: 0x0 + 0x40 + 0x1000)
# ####################################################################
# Masking quotation marks " by VBS in PS-code:
# You have to mask """""""" by create a " in a dialog (that's ridiculous !!!)
# ====================================================================
# Charset in VBA (0 - 127)
# https://docs.microsoft.com/de-de/office/vba/language/reference/user-interface-help/character-set-0127
# Charset in VBA (128–255)
# https://docs.microsoft.com/de-de/office/vba/language/reference/user-interface-help/character-set-128255
# VBA-Code                           Powershell-Code
# ====================================================================
# BACKSPACE Chr(8) /TAB    Chr(9)   $([char]8)  / $([char]9)
# LINEFEED  Chr(10)/RETURN Chr(13)  $([char]10) / $([char]13)
# ====================================================================
# 196 Ä Chr(196) / 228 ä Chr(228)   $([char]196) / $([char]228)
# 213 Õ Chr(213) / 245 õ Chr(245)   $([char]213) / $([char]245)
# 220 Ü Chr(220) / 252 ü Chr(252)   $([char]220) / $([char]252)
# 223 ß Chr(223) / 128 € Chr(128)   $([char]223) / $([char]128)
# ####################################################################
# PARAMETERS
# ####################################################################
# The meaning of the nType parameter is the same as it is in the
# Microsoft Win32 API MessageBox function. The following tables
# show the values and their meanings. You can add values in these
# tables to combine them.
# ====================================================================
# Button Types
# ====================================================================
# Decimal Hexadecimal Description
# 0       0x0         Show OK button.
# 1       0x1         Show OK and Cancel buttons.
# 2       0x2         Show Abort, Retry, and Ignore buttons.
# 3       0x3         Show Yes, No, and Cancel buttons.
# 4       0x4         Show Yes and No buttons.
# 5       0x5         Show Retry and Cancel buttons.
# 6       0x6         Show Cancel, Try Again, and Continue buttons.
# ====================================================================
# Icon Types
# ====================================================================
# Decimal Hexadecimal Description
# 16      0x10        Show "Stop Mark" icon.
# 32      0x20        Show "Question Mark" icon.
# 48      0x30        Show "Exclamation Mark" icon.
# 64      0x40        Show "Information Mark" icon.
# ====================================================================
# Other Type Values
# ====================================================================
# Decimal Hexadecimal Description
# 256     0x100       The second button is the default button.
# 512     0x200       The third button is the default button.
# 4096    0x1000      The message box is a system modal message box and
#                     appears in a topmost window.
# 524288  0x80000     The text is right-justified.
# 1048576 0x100000    The message and caption text display in
#                     right-to-left reading order, which is useful for
#                     some languages.
# ====================================================================
# The previous three tables do not cover all values for nType.
# For more information, see MessageBox Function:
# https://docs.microsoft.com/de-de/windows/win32/api/winuser/nf-winuser-messagebox
# ====================================================================
# Return Value
# ====================================================================
# The return value intButton (in STDOUT) is the number of the
# button that the user clicked, or is -1 if the message box timed
# out. The following table lists possible return values.
# ====================================================================
# Return Value
# Decimal Description
# -1      The user did not click a button before nSecondsToWait
#         seconds elapsed.
# 1       OK button
# 2       Cancel button
# 3       Abort button
# 4       Retry button
# 5       Ignore button
# 6       Yes button
# 7       No button
# 10      Try Again button
# 11      Continue button
# ====================================================================
# Example for Windows shell cmd.exe:
# ==================================
# powershell.exe -ep Bypass -noprofile -command (new-object -ComObject wscript.shell).Popup('Installation-Sequece of additional packages begins ... ' + $([char]10) + $([char]13) + $([char]10) + $([char]13) + 'This message will wait 4 seconds ...',4,'Information ...',0x0 + 0x40 + 0x1000) >nul 2>&1
# Example for Busybox shell applet with masking of special chars:
# ===============================================================
# powershell.exe -ep Bypass -noprofile -command \(new-object -ComObject wscript.shell\).Popup\(\'Installation-Sequece of additional packages begins ... \' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'This message will wait 4 seconds ...\',4,\'Information ...\',0x0 + 0x40 + 0x1000\) >/dev/null 2>&1

clear

echo "##########################################"
echo "# Pandoc Gui by Veit Berwig, ZIT-SH 2025 #"
echo "##########################################"
echo ""

# Save local path from Windows ENV "PWD"-var to LAPPDIR
export LAPPDIR=${PWD}

# Set searchpath to local execution
export PATH=$LAPPDIR:$LAPPDIR/engines/weasyprint:$LAPPDIR/engines/wkhtmltopdf:$PATH

ZENITYUNX="zenity.exe --unixeol --cygpath"
ZENITYWIN="zenity.exe"
PANDOCUNX="pandoc.exe"
PANDOCWIN="pandoc.exe"

# Select PDF-engine
# ####################################################################
# !! BE AWARE TO UNMASK THE CORRECT LINE OF PDF-ENGINE REQUEST UNDER:
# !! --- PDF-ENGINE-REQUESTS --- BELOW ...
PDFENGINE="wkhtmltopdf"
# PDFENGINE="weasyprint"

# Select CSS for PDF-Creation
# ####################################################################
CSSFILE="pandoc.css"
# CSSFILE="pandocmod.css"
# CSSFILE="prince.css"
# CSSFILE="wkhtmltopdf.css"

# Check for correct "chdir" into "curdir".
CHDIRTO="false"

if ! test -d "$APPDATA/pandoc/media"; then
  echo "Directory \"$APPDATA/pandoc\" will be created ..."
  mkdir -p "$APPDATA/pandoc/media" >/dev/null 2>&1
  if test -d "$APPDATA/pandoc/media"; then
    echo "Success: Directory created !"
    # ################################################################
    # WE HAVE TO CHANGE INTO A WRITABLE "curdir working directory"
    # FROM WHICH "pandoc" IS RUN, BECAUSE PANDOC WILL CREATE SOME
    # RANDOM-FILES HERE, DURING PDF-CREATION (i. e.: toP25FA.pdf,
    # toP2F49.html, etc.), ALTHOUGH THE $TMP- AND $TEMP-VARS ARE
    # EXISTENT. IF THIS IST NOT POSSIBLE, WE HAVE TO EXIT BECAUSE
    # UNDER WINDOWS, WE DON'T HAVE WRITE ACCESS UNDER THE
    # "PROGRAM FILES"-DIRECTORIES.
    # ################################################################
    chdir "$APPDATA/pandoc" && CHDIRTO=true
    if test ${CHDIRTO} == "false"; then
      echo "Abort: Error in changing into directory \"$APPDATA/pandoc\" !"
      powershell.exe -ep Bypass -noprofile -command \(new-object -ComObject wscript.shell\).Popup\(\'Abort: Error in changing into directory APPDATA/pandoc ! \' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'This message waits 6 seconds ...\',6,\'Error !\',0x0 + 0x10 + 0x1000\) >/dev/null 2>&1
      # read a
      exit 1
    else
      echo "Changing into directory..: \"$APPDATA/pandoc\" was successful, continuing ..."
    fi
  else 
    echo "Abort: Directory \"$APPDATA/pandoc/media\" was NOT created !"
    powershell.exe -ep Bypass -noprofile -command \(new-object -ComObject wscript.shell\).Popup\(\'Abort: Directory APPDATA/pandoc/media could not be created ! \' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'This message waits 6 seconds ...\',6,\'Error !\',0x0 + 0x10 + 0x1000\) >/dev/null 2>&1
    # read a
    exit 1
  fi
else 
    echo "Directory \"$APPDATA/pandoc/media\" already exists ..."
    # ################################################################
    # WE HAVE TO CHANGE INTO A WRITABLE "curdir working directory"
    # FROM WHICH "pandoc" IS RUN, BECAUSE PANDOC WILL CREATE SOME
    # RANDOM-FILES HERE, DURING PDF-CREATION (i. e.: toP25FA.pdf,
    # toP2F49.html, etc.), ALTHOUGH THE $TMP- AND $TEMP-VARS ARE
    # EXISTENT. IF THIS IST NOT POSSIBLE, WE HAVE TO EXIT BECAUSE
    # UNDER WINDOWS, WE DON'T HAVE WRITE ACCESS UNDER THE
    # "PROGRAM FILES"-DIRECTORIES.
    # ################################################################
    chdir "$APPDATA/pandoc" && CHDIRTO=true
    if test ${CHDIRTO} == "false"; then
      echo "Abort: Error in changing into directory \"$APPDATA/pandoc\" !"
      powershell.exe -ep Bypass -noprofile -command \(new-object -ComObject wscript.shell\).Popup\(\'Abort: Error in changing into directory APPDATA/pandoc ! \' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'This message waits 6 seconds ...\',6,\'Fehler !\',0x0 + 0x10 + 0x1000\) >/dev/null 2>&1
      # read a
      exit 1
    else
      echo "Changing into directory..: \"$APPDATA/pandoc\" was successful, continuing ..."
    fi
fi

# Get DATADIR with translated slashes to backslashes
DATADIR=$(cygpath.exe -w "$APPDATA/pandoc" | sed -e 's/\\/\\\\/g')
echo "data-dir ................: \"$APPDATA/pandoc\""
echo "extract-media ...........: \"$APPDATA/pandoc\""
echo "media dir ...............: \"$APPDATA/pandoc/media\""
echo "DATADIR .................: \"$DATADIR\""
echo "LAPPDIR .................: \"$LAPPDIR\""
echo "TEMP ....................: \"$TEMP\""
echo "TMP .....................: \"$TMP\""

# Splash-Message
powershell.exe -ep Bypass -noprofile -command \(new-object -ComObject wscript.shell\).Popup\(\'Pandoc Gui by Veit Berwig, ZIT-SH 2025\' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'Converting documents with Pandoc begins ... \' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'This message will wait 6 seconds ...\',6,\'Information ...\',0x0 + 0x40 + 0x1000\) >/dev/null 2>&1

ZENITY=false
PANDOC=false
${ZENITYWIN} --version >/dev/null 2>&1 && ZENITY=true
${PANDOCWIN} --version >/dev/null 2>&1 && PANDOC=true

if test ${ZENITY} == "false"; then
  echo "Abort: Zenity must be available in search-path to use this script !"
  powershell.exe -ep Bypass -noprofile -command \(new-object -ComObject wscript.shell\).Popup\(\'Abort: Zenity must be available in search-path to use this script ! \' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'This message will wait 6 seconds ...\',6,\'Error !\',0x0 + 0x10 + 0x1000\) >/dev/null 2>&1
  # read a
  exit 1
fi

if test ${PANDOC} == "false"; then
  echo "Abort: Pandoc must be available in search-path to use this script !"
  powershell.exe -ep Bypass -noprofile -command \(new-object -ComObject wscript.shell\).Popup\(\'Abort: Pandoc must be available in search-path to use this script ! \' + \$\(\[char\]10\) + \$\(\[char\]13\) + \$\(\[char\]10\) + \$\(\[char\]13\) + \'This message will wait 6 seconds ...\',6,\'Error !\',0x0 + 0x10 + 0x1000\) >/dev/null 2>&1
  # read a
  exit 1
fi

# Check if first paramter is there and is an existing file,
# represented by "$*" as FQDN.
if [ $1 ] && [ -s "$*" ]; then
  SOURCEFILE="$*"
else 
  if ! SOURCEFILE=$(${ZENITYWIN} --file-selection --title="Please choose the file you want to convert, using \"Pandoc\":");  then
    exit
  fi
fi

# echo "SOURCEFILE .............: \"$SOURCEFILE\""

# Output-Formats (20250112)
# Got them from: pandoc --list-output-formats
if ! CONVERTTO=$(${ZENITYWIN} --list --text="Mark the row with the mouse ..." --title="Please choose target format" --column=ansi \
  asciidoc \
  asciidoc_legacy \
  asciidoctor \
  beamer \
  biblatex \
  bibtex \
  chunkedhtml \
  commonmark \
  commonmark_x \
  context \
  csljson \
  djot \
  docbook \
  docbook4 \
  docbook5 \
  docx \
  dokuwiki \
  dzslides \
  epub \
  epub2 \
  epub3 \
  fb2 \
  gfm \
  haddock \
  html \
  html4 \
  html5 \
  icml \
  ipynb \
  jats \
  jats_archiving \
  jats_articleauthoring \
  jats_publishing \
  jira \
  json \
  latex \
  man \
  markdown \
  markdown_github \
  markdown_mmd \
  markdown_phpextra \
  markdown_strict \
  markua \
  mediawiki \
  ms \
  muse \
  native \
  odt \
  opendocument \
  opml \
  org \
  pdf \
  plain \
  pptx \
  revealjs \
  rst \
  rtf \
  s5 \
  slideous \
  slidy \
  tei \
  texinfo \
  textile \
  typst \
  xwiki \
  zimwiki); then
  exit
fi

# Filter for target-formats with same extensions (MAP)
# ####################################################
# Change extension to "md" for TARGET...-files, when target is:
# "markdown", "markdown_github", "markdown_phpextra"
# or "markdown_strict". Backup "CONVERTTO" into "CONVERTTOB".
#
CONVERTTOB="false"
if test ${CONVERTTO} == "markdown"; then
  CONVERTTOB="markdown"
  CONVERTTO="md"
fi
if test ${CONVERTTO} == "markdown_github"; then
  CONVERTTOB="markdown_github"
  CONVERTTO="md"
fi
if test ${CONVERTTO} == "markdown_mmd"; then
  CONVERTTOB="markdown_mmd"
  CONVERTTO="md"
fi
if test ${CONVERTTO} == "markdown_phpextra"; then
  CONVERTTOB="markdown_phpextra"
  CONVERTTO="md"
fi
if test ${CONVERTTO} == "markdown_strict"; then
  CONVERTTOB="markdown_strict"
  CONVERTTO="md"
fi

# echo "SOURCEFILE.CONVERTTO ...: \"$SOURCEFILE.$CONVERTTO\""

if test -f "$SOURCEFILE.$CONVERTTO"; then
  if ! OVERWRITE=$(${ZENITYWIN} -cancel-label "No" -ok-label "Yes" --question --title="Information" --text="File: \"$SOURCEFILE.$CONVERTTO\" already exists, overwrite ?"); then
    exit
  fi
fi

TARGETFULLPATH="$SOURCEFILE.$CONVERTTO"
TARGETNAME=${TARGETFULLPATH##*/}
SOURCENAME=${SOURCEFILE##*/}
echo "SOURCENAME .............: \"$SOURCENAME\""
echo "TARGETNAME .............: \"$TARGETNAME\""
# echo "TARGETFULLPATH .........: \"$TARGETFULLPATH\""

# Filter for target-formats with same extensions (REMAP)
# ######################################################
# Restore "CONVERTTO" back to original target-format,
# when "md" was defined.
#
if test ${CONVERTTOB} == "markdown"; then
  CONVERTTO="markdown"
fi
if test ${CONVERTTOB} == "markdown_github"; then
  CONVERTTO="markdown_github"
fi
if test ${CONVERTTOB} == "markdown_mmd"; then
  CONVERTTO="markdown_mmd"
fi
if test ${CONVERTTOB} == "markdown_phpextra"; then
  CONVERTTO="markdown_phpextra"
fi
if test ${CONVERTTOB} == "markdown_strict"; then
  CONVERTTO="markdown_strict"
fi

# Show commandline for debugging
# echo "---------------------------------------------------------------"
# echo "ENGINE: wkhtmltopdf"
# echo "DEBUG-OUTPUT: ${PANDOCWIN} --standalone --wrap=none --data-dir=\"$APPDATA/pandoc\" --resource-path=\"$APPDATA/pandoc\" --extract-media=\"$APPDATA/pandoc\" --pdf-engine=wkhtmltopdf --css \"$LAPPDIR/${CSSFILE}\" \"$SOURCEFILE\" -t $CONVERTTO -o \"$TARGETFULLPATH\""
# echo "###############################################################"
# echo "ENGINE: weasyprint"
# echo "DEBUG-OUTPUT: ${PANDOCWIN} --standalone --wrap=none --data-dir=\"$APPDATA/pandoc\" --resource-path=\"$APPDATA/pandoc\" --extract-media=\"$APPDATA/pandoc\" --pdf-engine=weasyprint --pdf-engine-opt=--stylesheet=\"$LAPPDIR/${CSSFILE}\" \"$SOURCEFILE\" -t $CONVERTTO -o \"$TARGETFULLPATH\""
# echo "---------------------------------------------------------------"

# SUBSHELL --- BEGIN ---
# Be aware, that we have no access to "stdout" and "stderr" subshells.
# Create a subshell in order to mask the exit-status of the
# executed process through the pipe of the "zenity --progress"
# request. Details: https://stackoverflow.com/a/44986065
(
  # Pre-define exit-status
  PANEXIT=false

  # --- PDF-ENGINE-REQUESTS ---
  
  # :: wkhtmltopdf ::
  # Using windows-style --data-dir with "\\" as delimiter.
  # --wrap=none is mandatory to avoid random quote block
  #   to be added to markdown
  # Set CSS-file for "wkhtmltopdf".
  # PANOUTPUT=$(${PANDOCWIN} --standalone --wrap=none --data-dir="$DATADIR" --resource-path="$DATADIR" --extract-media="$DATADIR" --pdf-engine=${PDFENGINE} --css "$LAPPDIR/${CSSFILE}" "$SOURCEFILE" -t $CONVERTTO -o "$TARGETFULLPATH" 2>&1) && PANEXIT=true

  # :: wkhtmltopdf ::
  # Using unix-style --data-dir with "/" as delimiter.
  # --wrap=none is mandatory to avoid random quote block
  #   to be added to markdown
  # Set CSS-file for "wkhtmltopdf".
  PANOUTPUT=$(${PANDOCWIN} --standalone --wrap=none --data-dir="$APPDATA/pandoc" --resource-path="$APPDATA/pandoc" --extract-media="$APPDATA/pandoc" --pdf-engine=${PDFENGINE} --css "$LAPPDIR/${CSSFILE}" "$SOURCEFILE" -t $CONVERTTO -o "$TARGETFULLPATH" 2>&1) && PANEXIT=true

  # :: weasyprint ::
  # Using unix-style --data-dir with "/" as delimiter.
  # --wrap=none is mandatory to avoid random quote block
  #   to be added to markdown
  # Set CSS-file for "weasyprint" with separate engine-option.
  # --pdf-engine-opt=--stylesheet=${CSSFILE}
  # --pdf-engine-opt=--pdf-variant=pdf/ua-1
  # PANOUTPUT=$(${PANDOCWIN} --standalone --wrap=none --data-dir="$APPDATA/pandoc" --resource-path="$APPDATA/pandoc" --extract-media="$APPDATA/pandoc" --pdf-engine=${PDFENGINE} --pdf-engine-opt=--stylesheet="$LAPPDIR/${CSSFILE}" "$SOURCEFILE" -t $CONVERTTO -o "$TARGETFULLPATH" 2>&1) && PANEXIT=true
  
  # Check exit-status and show error in GUI, when "false".
  if test ${PANEXIT} == "false"; then
    ${ZENITYWIN} -cancel-label "Cancel" -ok-label "Ok" --error --title="Error" --text="Error occured: ${PANOUTPUT}";
    # Exit from sub-shell, when error was raised.
    exit 1
  else
    ${ZENITYWIN} --info --title="Information" --text="File: \"$SOURCENAME\" converted to format: \"$CONVERTTO\" and saved under: \"$TARGETNAME\".";
    # exit
  fi
# SUBSHELL ---  END  ---

    # We do a fake-progress here, because we do not have any real
    # progress-strings to evaluate.
) | ${ZENITYWIN} --progress --pulsate --percentage=85 --no-cancel \
    --auto-close --title="Conversion running !" \
    --text="Please wait ..."
