#!/bin/sh 
NO_EXPIRY_DATE=5000 # 5000 days from now
#XMLDIR="/home/silvia/issue-data"
XMLDIR="/home/issuer/xml"

# args: $1 = root userID
#       $2 = PIN code
function write_thalia_root {
write_thalia_issue_script "/tmp/root-cred.xml" "$2"
cat >/tmp/root-cred.xml <<EOF
<CredentialIssueSpecification>
    <Name>Thalia lidinfo</Name>
    <IssuerID>Thalia</IssuerID>

    <Id>1337</Id>

    <Expires>$NO_EXPIRY_DATE</Expires>

    <Attributes>
        <Attribute type="string">
            <Name>userID</Name>
            <Value>$1</Value>
        </Attribute>
    </Attributes>
</CredentialIssueSpecification>
EOF
}

# args: $1 = expiry date (in days from now)
#       $2 = yes/no (isMember)
#       $3 = yes/no (isBegunstiger)
#       $4 = yes/no (isHonoraryMember)
#       $5 = PIN code
function write_thalia_member {
if ([ "$2" != "yes" ] && [ "$2" != "no"]) || ([ "$3" != "yes" ] && [ "$3" != "no" ]) || ([ "$4" != "yes" ] && [ "$4" != "no" ]) # TODO: make less ugly, use $@ or something like that
then
    echo Invalid member type: $@ echo Expected: yes/no yes/no yes/no
    exit 1
fi
write_thalia_issue_script "/tmp/member-cred.xml" "$5"
cat >/tmp/member-cred.xml <<EOF
<CredentialIssueSpecification>
    <Name>Thalia member type</Name>
    <IssuerID>Thalia</IssuerID>

    <Id>1338</Id>

    <Expires>$1</Expires>

    <Attributes>
        <Attribute type="string">
            <Name>isMember</Name>
            <Value>$2</Value>
        </Attribute>
        <Attribute type="string">
            <Name>isBegunstiger</Name>
            <Value>$3</Value>
        </Attribute>
        <Attribute type="string">
            <Name>isHonoraryMember</Name>
            <Value>$4</Value>
        </Attribute>
    </Attributes>
</CredentialIssueSpecification>
EOF
}

# args: $1 = yes/no (over18)
#       $2 = PIN code
function write_thalia_age {
if [ "$1" != "yes" ] && [ "$1" != "no" ]
then
    echo Invalid age: $1
    exit 1
fi
write_thalia_issue_script "/tmp/age-cred.xml" "$2"
cat >/tmp/age-cred.xml <<EOF
<CredentialIssueSpecification>
    <Name>Thalia leeftijd</Name>
    <IssuerID>Thalia</IssuerID>

    <Id>1339</Id>

    <Expires>$NO_EXPIRY_DATE</Expires>

    <Attributes>
        <Attribute type="string">
            <Name>over18</Name>
            <Value>$1</Value>
            </Attribute>
    </Attributes>
</CredentialIssueSpecification>
EOF
}


# args: $1 IssueSpecification
#       $2 PIN
function write_thalia_issue_script {
cat >/tmp/issue_script.xml <<EOF
<SilviaIssuingScript>
    <Description>Thalia issue script</Description>

    <UserPIN>$2</UserPIN>

    <Credentials>
        <Credential>
            <IssueSpecification>$1</IssueSpecification>
            <IssuerPublicKey>$XMLDIR/ipk.xml</IssuerPublicKey>
            <IssuerPrivateKey>$XMLDIR/isk.xml</IssuerPrivateKey>
        </Credential>
    </Credentials>
</SilviaIssuingScript>
EOF
}
