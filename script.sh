#!/bin/sh 

#imports:
# write_thalia_root , $1 = thalia root
# write_thalia_member, $1 = expiry date (in days from now) $2 = yes/no (isMember) $3 = yes/no (isBegunstiger) $4 = yes/no (isHonoraryMember)
# write_thalia_age, $1 = yes/no (over18)
# sets XMLDIR
source /home/silvia/script/write_xml.sh

issue_membership() { # $1 = thalia root attribute, $2 = PIN 
    expiry_date=30 # TODO: Thom get expiry date from thalia database
    isMember=yes  # TODO: Thom get this from database
    isBegunstiger=no # TODO: Thom get this from database
    isHonoraryMember=no # TODO: Thom get this from database
    echo "Issuing Thalia membership for user, with username" "$1"
    write_thalia_member $expiry_date $isMember $isBegunstiger $isHonoraryMember "$2" # Write the XML files
    sudo -u issuer /opt/bin/issueWithKey.sh
} 

issue_root() { # $1 = thalia root attribute, $2 = PIN
    echo "Issuing Thalia root, with username" "$1"
    write_thalia_root "$1" "$2" # Write the XML files
    sudo -u issuer /opt/bin/issueWithKey.sh
}

check_issue_age() { # $1 = thalia root attribute, $2 = PIN
    echo "Issuing Thalia age, for user name" "$1"
    over18=yes # TODO get this from thalia database
    write_thalia_age "$over18" "$2"
    sudo -u issuer /opt/bin/issueWithKey.sh
}

get_thalia_root() {
    # TODO 
    echo retrieving student number for "$1"...
    thalia_root="kingendummy"
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
    echo DEBUG: verify by thalia root
    echo Please enter your 4 digit IRMA pin code
    read -s UNTRUSTED
    PIN=${UNTRUSTED//[^0-9]/} # Strip all non digits
    issue_membership "$thalia_root" "$PIN"
    check_issue_age "$thalia_root" "$PIN"
else
    echo Invalid thalia root, trying to verify by student number...
    student_number="`/home/silvia/silvia/src/bin/verifier/silvia_verifier \
        -I /home/silvia/irma_configuration/Surfnet/Issues/root/description.xml \
        -k /home/silvia/irma_configuration/Surfnet/ipk.xml \
        -V /home/silvia/irma_configuration/Surfnet/Verifies/rootAll/description.xml | grep userID | cut -d \| -f2 | cut -d \@ -f1`"

    if [ -n "$student_number" ]; then
        get_thalia_root $student_number
        if [ -z "$thalia_root" ]; then
            echo "Invalid card! Contact identificaatcie@thalia.nu for support!"
            exit 1
        fi
        echo "Please enter your IRMA user pin code (usually 4 digits)"
        read -s UNTRUSTED
        PIN=${UNTRUSTED//[^0-9]/} # Strip all non-digits
        issue_root "$thalia_root" "$PIN"
        issue_membership "$thalia_root" "$PIN"
        check_issue_age "$thalia_root" "$PIN"
    else
        echo "Invalid card! Contact identificaatcie@thalia.nu for support!"
    fi
fi
