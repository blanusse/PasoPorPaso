
(:declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";:)
(:declare option output:method "xml";:)
(:declare option output:indent "yes";:)



declare variable $prefix external;

let $season := (//season[starts-with(@name, $prefix)])[1]
return
    if ($season) then
        string($season/@id)
    else
        ""