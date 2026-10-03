%-------------------------
% resume.cls -- shared class for every resume in this repo.
%
% Look: recreates reference/current_resume.pdf (a Google Docs export):
% Times-style serif, 10pt body, 0.75in margins, bold all-caps section
% headings over a full-width rule, round bullets at a 0.25in indent.
%
% Scaffolded from Jake's Resume:
%   Resume in Latex
%   Author : Jake Gutierrez
%   Based off of: https://github.com/sb2nov/resume
%   License : MIT
%
% MIT License
%
% Copyright (c) 2020 Jake Gutierrez
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%
% STABLE MACRO INTERFACE (fixtures, templates and skills rely on these;
% change the visuals freely, never the names or arities):
%   \resumeSubHeadingListStart / \resumeSubHeadingListEnd
%   \resumeSubheading{org}{dates}{title}{location}
%   \resumeItemListStart / \resumeItemListEnd
%   \resumeItem{text}
%   \resumeProjectHeading{name}{dates}
%
% Extra helpers (header and skills block):
%   \resumeName{name}  \resumeContact{items}  \resumeLink{url}{text}
%   \resumeSep         \resumeSkillListStart / \resumeSkillListEnd
%-------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2026/10/03 Resume class]
\LoadClass[letterpaper,11pt]{article}

\RequirePackage[T1]{fontenc}
\RequirePackage{tgtermes}          % TeX Gyre Termes: free Times New Roman match
\RequirePackage{latexsym}
\RequirePackage[letterpaper,margin=0.75in,headheight=0pt,headsep=0pt,footskip=12pt]{geometry}
\RequirePackage{titlesec}
\RequirePackage{marvosym}
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{enumitem}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{fancyhdr}
\RequirePackage[english]{babel}
\input{glyphtounicode}

% Ensure that generated PDF is machine readable/ATS parsable
\pdfgentounicode=1

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

% Body text is 10pt with single (Docs-style) line spacing, as in the reference.
\renewcommand{\normalsize}{\@setfontsize\normalsize\@xpt{11}}
\normalsize

\urlstyle{same}
\raggedbottom
\raggedright
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlength{\tabcolsep}{0in}

\definecolor{resumelink}{HTML}{1155CC}  % Google Docs link blue

%----------HEADER----------
\newcommand{\resumeName}[1]{%
  \begin{center}
    {\fontsize{18pt}{21pt}\selectfont\bfseries\MakeUppercase{#1}}%
  \end{center}\vspace{-8pt}}
\newcommand{\resumeContact}[1]{%
  \begin{center}
    {\@setfontsize\resume@contactsize\@xipt{13}#1}%
  \end{center}\vspace{1pt}}
\newcommand{\resumeLink}[2]{\href{#1}{\textcolor{resumelink}{\underline{\raisebox{0pt}[\height][1.5pt]{#2}}}}}
\newcommand{\resumeSep}{\ \textbf{|}\ }

%----------SECTIONS----------
\titleformat{\section}{\normalfont\normalsize\bfseries}{}{0em}{\MakeUppercase}[\vspace{-1pt}\titlerule]
\titlespacing*{\section}{0pt}{10pt}{5pt}

%----------ENTRIES----------
\newcommand{\resume@ifempty}[3]{\if\relax\detokenize{#1}\relax#2\else#3\fi}

% Entries: no indent, a blank line's worth of space between them.
\newcommand{\resumeSubHeadingListStart}{%
  \begin{itemize}[leftmargin=0pt,labelwidth=0pt,labelsep=0pt,label={},
                  topsep=0pt,partopsep=0pt,parsep=0pt,itemsep=10pt]}
\newcommand{\resumeSubHeadingListEnd}{\end{itemize}}

% Line 1: bold org -- location, dates flush right. Line 2: italic title.
\newcommand{\resumeSubheading}[4]{%
  \item \textbf{#1}\resume@ifempty{#4}{}{ -- #4}\hfill #2\\
  \textit{#3}}

% Line 1: name (caller formats, e.g. \textbf{X} $|$ \emph{Y}), dates flush right.
\newcommand{\resumeProjectHeading}[2]{%
  \item #1\hfill #2}

% Bullets: round bullet at 0.25in, wrapped text hangs at 0.5in.
\newcommand{\resumeBullet}{\raisebox{-0.25ex}{\Large\textbullet}}
\newcommand{\resumeItemListStart}{%
  \begin{itemize}[leftmargin=0.5in,labelwidth=0.25in,labelsep=0pt,align=left,
                  label=\resumeBullet,topsep=0pt,partopsep=0pt,parsep=0pt,itemsep=0pt]}
\newcommand{\resumeItemListEnd}{\end{itemize}}
\newcommand{\resumeItem}[1]{\item #1}

% Skills block: same bullets, flush with the margin.
\newcommand{\resumeSkillListStart}{%
  \begin{itemize}[leftmargin=0.25in,labelwidth=0.25in,labelsep=0pt,align=left,
                  label=\resumeBullet,topsep=0pt,partopsep=0pt,parsep=0pt,itemsep=0pt]}
\newcommand{\resumeSkillListEnd}{\end{itemize}}

\endinput
