#!/bin/sh 
rm -f /tmp/*.xml
setterm -blank 0 -powerdown 0

clear

set -e

#imports:
# write_thalia_root , $1 = thalia root
# write_thalia_member, $1 = expiry date (in days from now) $2 = yes/no (isMember) $3 = yes/no (isBegunstiger) $4 = yes/no (isHonoraryMember)
# write_thalia_age, $1 = yes/no (over18)
# sets XMLDIR
source /home/silvia/script/write_xml.sh
APILEZER="python3 /home/silvia/script/lezer.py"

issue_membership() { # $1 = member result from website, $2 = PIN 
    expiry_date=$(python3 /home/silvia/script/days_to_august31.py)
    TYPE=$(echo $1 | cut -d' ' -f2)
    isMember=$(test "$TYPE" == "member" && echo "yes" || echo "no")
    isBegunstiger=$(test "$TYPE" == "begunstiger" && echo "yes" || echo "no")
    isHonoraryMember=$(test "$TYPE" == "honoraryMember" && echo "yes" || echo "no")
    if [ "$isMember" == "no" ] && [ "$isBegunstiger" == "no" ] && [ "$isHonoraryMember" == "no" ]
    then
	    echo "You don't seem to be a Thalia member this year, not issueing Membership..."
    else
	    echo "Issuing Thalia membership for user, with username" "$1"
	    write_thalia_member $expiry_date $isMember $isBegunstiger $isHonoraryMember "$2" # Write the XML files
	    sudo -u issuer /opt/bin/issueWithKey.sh
    fi
} 

issue_root() { # $1 = thalia root attribute, $2 = PIN
    echo "Issuing Thalia root, with username" "$1"
    write_thalia_root "$1" "$2" # Write the XML files
    sudo -u issuer /opt/bin/issueWithKey.sh
}

check_issue_age() { # $1 = member result from website, $2 = PIN
    echo "Issuing Thalia age, for user name" "$1"
    over18=$(echo $1 |cut -d ' '  -f3)
    write_thalia_age "$over18" "$2"
    sudo -u issuer /opt/bin/issueWithKey.sh
}

figlet -c "IRMA kiosk"
echo "Please enter your IRMA-card"

#set -e # terminate after error
# get thalia root from card
thalia_root="`/home/silvia/silvia/src/bin/verifier/silvia_verifier \
 -I /home/silvia/irma_configuration/Thalia/Issues/root/description.xml \
 -k /home/silvia/irma_configuration/Thalia/ipk.xml \
 -V /home/silvia/irma_configuration/Thalia/Verifies/rootAll/description.xml | grep userID | cut -d \| -f2`"

if [ -n "$thalia_root" ]; then
    echo "You have a valid root credential!"
    echo Please enter your 4 digit IRMA pin code
    read -s UNTRUSTED
    PIN=${UNTRUSTED//[^0-9]/} # Strip all non digits
    MEMBER=$($APILEZER thalia_username  "$thalia_root")
    issue_membership "$MEMBER" "$PIN"
    check_issue_age "$MEMBER" "$PIN"
    echo "Your credentials have been re-issued!"
else
    echo Invalid thalia root, trying to verify by student number...
    student_number="`/home/silvia/silvia/src/bin/verifier/silvia_verifier \
        -I /home/silvia/irma_configuration/Surfnet/Issues/root/description.xml \
        -k /home/silvia/irma_configuration/Surfnet/ipk.xml \
        -V /home/silvia/irma_configuration/Surfnet/Verifies/rootAll/description.xml | grep userID | cut -d \| -f2 | cut -d \@ -f1`"

    if [ -n "$student_number" ]; then
        MEMBER=$($APILEZER student_number "$student_number") || ( echo $MEMBER ; sleep 10; exit 1 )
        thalia_root=$(echo $MEMBER | cut -d ' ' -f1)
        echo "Please enter your IRMA user pin code (usually 4 digits)"
	setleds -D +num
        read -s UNTRUSTED
        PIN=${UNTRUSTED//[^0-9]/} # Strip all non-digits
        issue_root "$thalia_root" "$PIN"
        issue_membership "$MEMBER" "$PIN"
        check_issue_age "$MEMBER" "$PIN"
        echo "Your credentials have been re-issued!"
    else
        echo "Invalid card! Contact identificaatcie@thalia.nu for support!"
    fi
fi
sleep 10
