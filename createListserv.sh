#!/usr/bin/bash
#
#  This script will create a new mailman listserv & the associated LDAP entries.
#  
#  It calls /opt/mailman/bin/newlist:
#  newlist [options] [listname [listadmin-addr [admin-password]]]
#

# LDIF file for adding Mailman Listservs
LDIF=/usr/local/admin/cls.ldif

# USAGE
if [ $# -ne 3 ]; then
   echo "usage: createListserv.sh <listname> <listadmin-addr> <admin-passwd>"
   exit
fi

# -h option
if [ ${1} = "-h" ]; then
   echo "usage: createListserv.sh <listname> <listadmin-addr> <admin-passwd>"
   exit
fi

# remove an existing LDIF file
if [ -f ${LDIF} ]; then
   rm -i ${LDIF}
fi

# check to see if the list already exists in ldap
var=`ldapsearch -Lb o=kutztown.edu cn=${1} dn`

# if the list doesn exist, begin creating it
if [ "${var}" = "" ]; then
   # check to see if the administrator's email address exists
   admaddr=`ldapsearch -Lb o=kutztown.edu mail=${2} dn`
   if [ "${admaddr}" = "" ]; then
      # administrator's email address does not exist 
      echo "listadmin-addr, ${2}, does not exist"
      echo "usage: createListserv.sh <listname> <listadmin-addr> <admin-passwd>"
      exit
   fi

  # List name does not exist, but administrator's email address does
  # use newlist to create the list in mailman
  /opt/mailman/bin/newlist ${1} ${2} ${3}

   # build the LDIF file to create the correct LDAP entries
   echo "dn: cn=${1},ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}" >> $LDIF
   echo "businessCategory: ${1}@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-admin,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-admin@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-admin@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-admin" >> $LDIF
   echo "businessCategory: ${1}-admin@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-bounces,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-bounces@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-bounces@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-bounces" >> $LDIF
   echo "businessCategory: ${1}-bounces@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-confirm,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-confirm@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-confirm@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-confirm" >> $LDIF
   echo "businessCategory: ${1}-confirm@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-join,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-join@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-join@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-join" >> $LDIF
   echo "businessCategory: ${1}-join@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-leave,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-leave@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-leave@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-leave" >> $LDIF
   echo "businessCategory: ${1}-leave@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-owner,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-owner@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-owner@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-owner" >> $LDIF
   echo "businessCategory: ${1}-owner@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-request,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-request@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-request@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-request" >> $LDIF
   echo "businessCategory: ${1}-request@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-subscribe,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-subscribe@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-subscribe@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-subscribe" >> $LDIF
   echo "businessCategory: ${1}-subscribe@v880.kutztown.edu" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-unsubscribe,ou=groups,o=kutztown.edu" >> $LDIF
   echo "mailProgramDeliveryInfo: mailmanWrapper" >> $LDIF
   echo "mailDeliveryOption: program" >> $LDIF
   echo "mailAlternateAddress: ${1}-unsubscribe@v880.kutztown.edu" >> $LDIF
   echo "mail: ${1}-unsubscribe@kutztown.edu" >> $LDIF
   echo "mailHost: v880.kutztown.edu" >> $LDIF
   echo "objectClass: top" >> $LDIF
   echo "objectClass: inetLocalMailRecipient" >> $LDIF
   echo "objectClass: inetMailGroup" >> $LDIF
   echo "objectClass: groupOfUniqueNames" >> $LDIF
   echo "inetMailGroupStatus: active" >> $LDIF
   echo "cn: ${1}-unsubscribe" >> $LDIF
   echo "businessCategory: ${1}-unsubscribe@v880.kutztown.edu" >> $LDIF
  
   # Add the list's ldap entries to the directory 
   PASSWORD=`cat /usr/local/admin/conf/conf.dir`
   ldapmodify -a -h sbv100-3.kutztown.edu -D "cn=directory manager" -w $PASSWORD -f ${LDIF}
else 
   # List already exists, please search for a different name
   echo "listname ${1} exists, please try a different name"
   echo "usage: createListserv.sh <listname> <listadmin-addr> <admin-passwd>"
   exit
fi
