#Requires AutoHotkey v2.0

; ctrl+alt+shft+w
^!+w:: ExitApp

:o:.bold::''''''{Left 3}
:o:.ins::<u></u>{left 4}
:o:.ital::''''{Left 2}
:o:.big::<big></big>{Left 6}
:o:.small::<small></small>{Left 8}
:o:.center::<center></center>{Left 9}
:o:.span::<span></span>{Left 7}
:o:.br::<br/>
:o:.syntax::<syntaxhighlight lang=""></syntaxhighlight>{Left 20}
:o:.nowiki::<nowiki></nowiki>{Left 9}
:o:.think::<!--  -->{Left 4}
:o:.link::<link>|</link>{Left 8}
:o:.table::
    (
    {|
    ! <Header 1>
    ! <Header 2>
    |-
    | <Text 1>
    | <Text 2>
    |-
    |}
    )
:r:.why::{{Why|<Enter Text Here>}}
:r:.tip::{{Tip|<Enter Text Here>}}
:r:.note::{{Note|<Enter Text Here>}}
:r:.caution::{{Caution|<Enter Text Here>}}
:r:.warning::{{Warning|<Enter Text Here>}}
:r:.stop::{{Stop|<Enter Text Here>}}
:r:.watchout::{{Watchout|<Enter Text Here>|<Width%>}}
:r:.msgbox::{{Messagebox|[[Image:DesiredImage.gif]]|<Enter Text Here>}}
:r:.info::{{Info|<Enter Text Here>}}
:r:.tldr::{{TLDR|<Enter Text Here>}}
:r:.compare::{{Compare|<Previous behavior in past tense.>|<Current behavior in present tense.>}}
:r:.trap::{{Trap|<Enter Text Here>}}
:r:.droids::{{Droids|<message>|<title>}}
:r:.mariojump::{{MarioJump|<Enter Text Here>}}
:r:.spicy::{{Spicy|<Enter Text Here>}}
:r:.officehours::{{OfficeHours|<Enter Text Here>}}
:r:.question::{{Question|<question>|<answer>}}
:r:.todo::{{TODO|<Enter Text Here>}}
:r:.underconstruction::{{Under Construction|<Enter Text Here>}}
:r:.outofdate::{{OutOfDate|<Enter Text Here>}}