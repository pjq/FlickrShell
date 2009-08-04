#########################################################################
# Author: pengjianqing@gmail.com
# Created Time: Mon 03 Aug 2009 07:48:46 PM CST
# File Name: flickr.sh
# Description:Please visit www.impjq.net for more information about this shell.
#########################################################################
#!/bin/bash

alias wget='wget -b'
CONFIGFILE=flickr.conf

echo "config file=${CONFIGFILE}"
API_KEY=`grep -v "#" ${CONFIGFILE}|grep API_KEY |cut -d "=" -f2`
API_SECRET=`grep -v "#" ${CONFIGFILE}|grep API_SECRET|cut -d "=" -f2`
OUTPUTDIR=`grep -v "#" ${CONFIGFILE}|grep OUTPUTDIR|cut -d "=" -f2`

TOKENXML=token.xml
FROBXML=frob.xml
INFOXML=info.xml
BLOGLISTXML=bloglist.xml
POSTBLOGRESULTXML=postblogresult.xml
SERVICESLISTXML=serviceslist.xml
COMMONSINSTITUTIONSXML=commonsinstitutions.xml
CONTACTLIST=contactlist.xml
CONTACTLISTPUBLICLIST=contactlistpublislist.xml
CONTACTLISTRECENTUPLOAD=contactlistrecentupload.xml

#Groub
GROUPBROWSERXML=groupbrowser.xml
GROUPSEARCHXML=groupsearchbrowser.xml
GROUPINFOXML=groupinfo.xml
GROUPMEMBERSLISTXML=groupmemberslist.xml
GROUPPOOLSGETGROUPLISTXML=grouppoolsgetgrouplist.xml

#interestingness
INTERESTINGNESSXML=interestingness.xml

#machinetags
MACHINETAGSNAMESPACES=machinetagsnamespaces.xml
MACHINETAGSGETPAIRS=machinetagsgetpairs.xml
MACHINETAGSGETPREDICATES=machinetagsgetpredicates.xml
MACHINETAGSGETRECENTVALUES=machinetagsgetrecentvalues.xml
MACHINETAGSGETVALUES=machinetagsgetvalues.xml
#echo "API_KEY=${API_KEY}"
#echo "API_SECRET=${API_SECRET}"

[ -d ${OUTPUTDIR} ]||{ echo "No such dir,so mkdir ${OUTPUTDIR}";mkdir ${OUTPUTDIR}; }

getInfo()
{
    echo "*********************************************************"
    echo "Get Info..."
    echo "*********************************************************"
    METHORD=flickr.people.getInfo
    OUTPUTFILE=${OUTPUTDIR}/${INFOXML}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE} 
    cat ${OUTPUTFILE} 
}

getBloglist()
{
    echo "*********************************************************"
    echo "Get blog list..."
    echo "*********************************************************"
    METHORD=flickr.blogs.getList
    OUTPUTFILE=${OUTPUTDIR}/${BLOGLISTXML}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE} 
    cat   ${OUTPUTFILE} 
}

postPhoto()
{
    echo "*********************************************************"
    echo "Sent a post to blog..."
    echo "*********************************************************"
    METHORD=flickr.blogs.postPhoto
    OUTPUTFILE=${OUTPUTDIR}/${POSTBLOGRESULTXML}
    PHOTO_ID=3783563309
    echo "Please choose the blog you want to post a photo:"
    BLOGS=`cat ${OUTPUTDIR}/${BLOGLISTXML}|grep id|cut -d "=" -f3|sed 's/"//g'|sed 's/service//g'|grep -n ""`
    echo "${BLOGS}"
    read -p "Enter your choice:" CHOOSE
    BLOGNAME=`echo "${BLOGS}"|grep "^${CHOOSE}"|cut -d ":" -f2`
    echo BLOGNAME=${BLOGNAME}
    BLOG_ID=`grep ${BLOGNAME} ${OUTPUTDIR}/${BLOGLISTXML}|cut -d "\"" -f2`

    read -p "Enter the password:" PASSWORD
    read -p "Enter the Title:" TITLE
    read -p "Enter the Description:" DESCRIPTION 
    #PASSWORD="QCS%23271773661"
    echo PASSWORD=${PASSWORD}

    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}blog_id${BLOG_ID}blog_password${PASSWORD}description${DESCRIPTION}method${METHORD}photo_id${PHOTO_ID}title${TITLE}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    PASSWORD=`echo ${PASSWORD}|sed 's/\#/%23/g'|sed 's/@/%40/g'`
    TITLE=`echo ${TITLE}|sed 's/ /+/g'`
    DESCRIPTION=`echo ${DESCRIPTION}|sed 's/ /+/g'`
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&blog_id=${BLOG_ID}&photo_id=${PHOTO_ID}&title=${TITLE}&description=${DESCRIPTION}&blog_password=${PASSWORD}&auth_token=${TOKEN}&api_sig=${API_SIG}"
    wget  ${FLICKR_URL} -O ${OUTPUTFILE} 
    cat ${OUTPUTFILE} 
}


getServiceslist()
{
    echo "*********************************************************"
    echo "Get Services list..."
    echo "*********************************************************"
    METHORD=flickr.blogs.getServices
    OUTPUTFILE=${OUTPUTDIR}/${SERVICESLISTXML}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE} 
    cat ${OUTPUTFILE} 
}

getToken()
{
    echo "*********************************************************"
    echo "Get frob..."
    echo "*********************************************************"
    URL=http://flickr.com/services/rest/?
    OUTPUTFILE=${OUTPUTDIR}/${FROBXML}
    METHORD=flickr.auth.getFrob
    SIG=${API_SECRET}api_key${API_KEY}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="${URL}method=${METHORD}&api_key=${API_KEY}&api_sig=${API_SIG}"
    echo FLICKR_URL=${FLICKR_URL}
    wget  ${FLICKR_URL} -O ${OUTPUTFILE} 

    FROB=`cat ${OUTPUTFILE}|grep frob|cut -d "<" -f2|cut -d ">" -f2`
    echo FROB=${FROB}

    echo "*********************************************************"
    echo "Load firefox to Confirm the authentication."
    echo "*********************************************************"
    SIG=${API_SECRET}api_key${API_KEY}frob${FROB}permswrite
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}

    FLICKR_URL="http://flickr.com/services/auth/?api_key=${API_KEY}&perms=write&frob=${FROB}&api_sig=${API_SIG}"
    echo "Loading ${FLICKR_URL}"
    firefox ${FLICKR_URL}
    read -p "Check OK[yes/no]:" CHOOSE
    echo Your input:${CHOOSE}

    METHORD=flickr.auth.getToken
    OUTPUTFILE=${OUTPUTDIR}/${TOKENXML}
    SIG=${API_SECRET}api_key${API_KEY}frob${FROB}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}

    FLICKR_URL="http://flickr.com/services/rest/?method=flickr.auth.getToken&api_key=${API_KEY}&frob=${FROB}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE} 
    cat ${OUTPUTFILE} 
    TOKEN=`cat ${OUTPUTFILE}|grep -i token|cut -d ">" -f2|cut -d "<" -f1`
    #sed -i '/^TOKEN/d' ${CONFIGFILE} 
    #echo "TOKEN=${TOKEN}" >>${CONFIGFILE} 
    sed -i '/^TOKEN/s/$/'${TOKEN}'/g' ${CONFIGFILE} 
    echo TOKEN=${TOKEN}
}

getCommonsInstitutions()
{
    echo "*********************************************************"
    echo "Get flickr.commons.getInstitutions"
    echo "*********************************************************"

    METHORD=flickr.commons.getInstitutions
    OUTPUTFILE=${OUTPUTDIR}/${COMMONSINSTITUTIONSXML}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}

getContact()
{
    echo "*********************************************************"
    echo "Get contact list..."
    echo "*********************************************************"
    METHORD=flickr.contacts.getList
    OUTPUTFILE=${OUTPUTDIR}/${CONTACTLIST}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}

    echo "*********************************************************"
    echo "Get getListRecentlyUploaded"
    echo "*********************************************************"
    METHORD=flickr.contacts.getListRecentlyUploaded
    OUTPUTFILE=${OUTPUTDIR}/${CONTACTLISTRECENTUPLOAD}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}


    echo "*********************************************************"
    echo "Get flickr.contacts.getPublicList"
    echo "*********************************************************"
    USER_ID=`grep nsid ${OUTPUTDIR}/${TOKENXML}|cut -d "\"" -f2`
    echo USER_ID=${USER_ID}
    OUTPUTFILE=${OUTPUTDIR}/${CONTACTLISTPUBLICLIST}
    #USER_ID=40112025%40N03
    METHORD=flickr.contacts.getPublicList
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}user_id${USER_ID}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    USER_ID=`echo ${USER_ID}|sed 's/@/%40/g'`
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&user_id=${USER_ID}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}


groupBrowser()
{
    echo "*********************************************************"
    echo "Group Browser"
    echo "*********************************************************"
    METHORD=flickr.groups.browse
    OUTPUTFILE=${OUTPUTDIR}/${GROUPBROWSERXML}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}
groupSearch()
{
    echo "*********************************************************"
    echo "Group Search "
    echo "*********************************************************"
    METHORD=flickr.groups.search
    OUTPUTFILE=${OUTPUTDIR}/${GROUPSEARCHXML}
    read -p "Input a group to search:" TEXT
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}text${TEXT}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&text=${TEXT}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}
getGroupInfo()
{
    echo "*********************************************************"
    echo "Get Group Info"
    echo "*********************************************************"
    METHORD=flickr.groups.getInfo
    OUTPUTFILE=${OUTPUTDIR}/${GROUPINFOXML}
    read -p "Input the group Id:" GROUP_ID
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}group_id${GROUP_ID}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    GROUP_ID=`echo ${GROUP_ID}|sed 's/@/%40/g'`
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}group_id${GROUP_ID}&auth_token=${TOKEN}&api_sig=${API_SIG}"
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&group_id=${GROUP_ID}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}

getGroupList()
{
    #The directory is newer than the file.
    if [ ${OUTPUTDIR}  -nt  ${OUTPUTDIR}/${GROUPPOOLSGETGROUPLISTXML} ];then
	getPoolsGroupList
    fi
    #    cat ${GROUPPOOLSGETGROUPLISTXML}|grep nsid|awk -F "\"" '{print $2 ":" $6}'|grep -n ""
}

getGroupMembersList()
{
    echo "*********************************************************"
    echo "Get Group members list"
    echo "*********************************************************"
    METHORD=flickr.groups.members.getList
    OUTPUTFILE=${OUTPUTDIR}/${GROUPMEMBERSLISTXML}
    echo "Here you can enter a group id."
    echo "if input nothing,you will choose the group your have joined(Suggest)"
    read -p "Input the group Id:" GROUP_ID
    if [ -z "${GROUP_ID}" ];then 
	getGroupList
	GROUPLIST=`cat ${OUTPUTDIR}/${GROUPPOOLSGETGROUPLISTXML}|grep nsid|awk -F "\"" '{print $2 ":" $6}'|grep -n ""`
	echo "${GROUPLIST}"
	read -p "Input your choise:" GROUP_ID
	GROUP_ID=`echo "${GROUPLIST}"|grep "^${GROUP_ID}"|cut -d ":" -f2`
    fi

    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}group_id${GROUP_ID}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    GROUP_ID=`echo ${GROUP_ID}|sed 's/@/%40/g'`
    FLICKR_URL="http://flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}group_id${GROUP_ID}&auth_token=${TOKEN}&api_sig=${API_SIG}"
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&group_id=${GROUP_ID}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}


getPoolsGroupList()
{
    echo "*********************************************************"
    echo "Get Group Pools List"
    echo "*********************************************************"
    METHORD=flickr.groups.pools.getGroups
    OUTPUTFILE=${OUTPUTDIR}/${GROUPPOOLSGETGROUPLISTXML}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}
groupMenu()
{
    echo "*******Group Operations Menu(Flickr.com)**************************************"
    echo "Please select:"
    echo "1.Group Browser"
    echo "2.Group Search"
    echo "3.Get Group Info"
    echo "4.Get GroupMembersList"
    echo "5.Get Group Pools List"
    echo "q.Back to the pre Menu"
}

group()
{
    echo "*********************************************************"
    echo "About Group Operation"
    echo "*********************************************************"

    groupMenu
    read -p "Please Select:" CHOOSE
    while [ ${CHOOSE} != "q"  ];do
	case ${CHOOSE} in
	    "1"  ) groupBrowser;;
	    "2"  ) groupSearch;;
	    "3"  ) getGroupInfo;;
	    "4"  ) getGroupMembersList;;
	    "5"  ) getPoolsGroupList;;
	    "q"  ) exit 0;;

	    "*"  ) echo "Wrong Selection";; 
	esac

	groupMenu
	read -p "Please Select:" CHOOSE
	clear
    done

}


getInterestingnessList()
{
    echo "*********************************************************"
    echo "Get Interestingness List"
    echo "*********************************************************"
    METHORD=flick.interestingness.getList
    OUTPUTFILE=${OUTPUTDIR}/${INTERESTINGNESSXML}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}

machinetagsGetNamespaces()
{
    echo "*********************************************************"
    echo "machinetags.getNamespaces"
    echo "*********************************************************"
    METHORD=flickr.machinetags.getNamespaces
    OUTPUTFILE=${OUTPUTDIR}/${MACHINETAGSNAMESPACES}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}

machinetagsGetPairs()
{
    echo "*********************************************************"
    echo "machinetags.getPairs"
    echo "*********************************************************"
    METHORD=flickr.machinetags.getPairs
    OUTPUTFILE=${OUTPUTDIR}/${MACHINETAGSGETPAIRS}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}

machinetagsGetPredicates()
{
    echo "*********************************************************"
    echo "machinetags.getPredicates"
    echo "*********************************************************"
    METHORD=flickr.machinetags.getPredicates
    OUTPUTFILE=${OUTPUTDIR}/${MACHINETAGSGETPREDICATES}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}
machinetagsGetRecentValues()
{
    echo "*********************************************************"
    echo "machinetags.getGetRecentValues"
    echo "*********************************************************"
    METHORD=flickr.machinetags.getRecentValues
    OUTPUTFILE=${OUTPUTDIR}/${MACHINETAGSGETRECENTVALUES}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}

machinetagsGetValues()
{
    echo "*********************************************************"
    echo "machinetags.getValues"
    echo "I will just exit this function,because here we need two  argus:namespace,predicate"
    echo "Now I don't know what is the meaning of namespace and predicate"
    echo "*********************************************************"
    exit 0

    METHORD=flickr.machinetags.getValues
    OUTPUTFILE=${OUTPUTDIR}/${MACHINETAGSGETVALUES}
    SIG=${API_SECRET}api_key${API_KEY}auth_token${TOKEN}method${METHORD}
    echo SIG=${SIG}
    API_SIG=`java md5 ${SIG}`
    echo API_SIG=${API_SIG}
    FLICKR_URL="http://api.flickr.com/services/rest/?method=${METHORD}&api_key=${API_KEY}&auth_token=${TOKEN}&api_sig=${API_SIG}"

    wget  ${FLICKR_URL} -O ${OUTPUTFILE}
    cat ${OUTPUTFILE}
}


machinetagsMenu()
{
    echo "*******mechinetags Menu(impjq.net)**************************************"
    echo "Please select:"
    echo "1.machinetagsGetNamespaces"
    echo "2.machinetagsGetPairs"
    echo "3.machinetagsGetPredicates"
    echo "4.machinetagsGetRecentValues"
    echo "5.machinetagsGetValues"
    echo "q.Back to the pre Menu"
}

machinetags()
{
    machinetagsMenu
    echo "*********************************************************"
    echo "About machinetags Operation"
    echo "*********************************************************"

    read -p "Please Select:" CHOOSE
    while [ ${CHOOSE} != "q"  ];do
	case ${CHOOSE} in
	    "1"  ) machinetagsGetNamespaces;;
	    "2"  ) machinetagsGetPairs;;
	    "3"  ) machinetagsGetPredicates;;
	    "4"  ) machinetagsGetRecentValues;;
	    "5"  ) machinetagsGetValues;;
	    "q"  ) exit 0;;

	    "*"  ) echo "Wrong Selection";; 
	esac

	machinetagsMenu
	read -p "Please Select:" CHOOSE
	clear
    done

}


checkConfigfile()
{
    if [ -e ${CONFIGFILE} ];then
	echo "*******************************************************************"
	echo "Your config file:${CONFIGFILE} already exists."
	echo "*******************************************************************"
	echo "Now check the API_KEY and API_SECRET"
	echo "*******************************************************************"
	API_KEY=`grep -v "#" ${CONFIGFILE}|grep API_KEY |cut -d "=" -f2`
	API_SECRET=`grep -v "#" ${CONFIGFILE}|grep API_SECRET|cut -d "=" -f2`
	OUTPUTDIR=`grep -v "#" ${CONFIGFILE}|grep OUTPUTDIR|cut -d "=" -f2`
	if [ -z ${API_KEY} ] || [  -z ${API_SECRET}  ] || [ -z ${OUTPUTDIR} ] ;then
	    echo "Your config file seems having some problem,Please check it."
	    echo "*******************************************************************"
	    exit 0
	fi


    else
	echo "*******************************************************************"
	echo "Your config file:${CONFIGFILE} doesn't exist,Now create the file."
	touch ${CONFIGFILE}
	echo "API_KEY=" >>${CONFIGFILE}
	echo "API_SECRET=" >>${CONFIGFILE}
	echo "OUTPUTDIR=./xml">>${CONFIGFILE}
	echo "TOKEN=">>${CONFIGFILE}
	echo "*******************************************************************"
	echo "Create successfully,Now Please edit your config file,then restart this shell "
	echo "*******************************************************************"
	exit 0

    fi
}

myhelp()
{
    echo "This shell is used to test the Flickr API,for more information,Please visit my site:www.impjq.net"

}

mainMenu()
{
    echo "*******Main Menu(impjq.net)**************************************"
    echo "Please select your action:"
    echo "1.Get Info"
    echo "2.Get blog list"
    echo "3.Get services list"
    echo "4.Post a photo to your blog"
    echo "5.Get Commons Institutions"
    echo "6.Get Contact list(including recently upload and public list)"
    echo "7.Group Operations"
    echo "              =>>Have sub menu"
    echo "8.Get interestingness list"
    echo "9.machinetags operation"
    echo "              =>>Have sub menu"

    echo "h.Enter this for help information"
    echo "q.Enter this to exit"
    echo "*******************************************************************"
}


echo "*******************************************************************"
echo "Here is the main function. "
echo "*******************************************************************"
echo "First check your config file "
checkConfigfile
echo "Your config file is correct,Now get the auth token..."
echo "If does't exist in the config file,it will re-get the token from flickr.com ..."
echo "*******************************************************************"
#TOKEN=`grep -v "#" ${CONFIGFILE}|grep "TOKEN"|cut -d "=" f2` 
TOKEN=`grep -v "#" ${CONFIGFILE}|grep "TOKEN"|cut -d "=" -f2`
echo TOKEN=${TOKEN}

if [ -z "${TOKEN}" ];then 
    getToken
fi

echo "*******************************************************************"
echo "Now you can use this token to Communication with flickr.com"
echo "Here you can select what you want to do in this simple menu."
echo "*******************************************************************"
mainMenu
read -p "Please Select:" CHOOSE

while [ "${CHOOSE}" != "q" ];do
    case "${CHOOSE}" in 
	"1" ) getInfo;;
	"2" ) getBloglist;;
	"3" ) getServiceslist;;
	"4" ) postPhoto;;
	"5" ) getCommonsInstitutions;;
	"6" ) getContact;;
	"7" ) group;;
	"8" ) getInterestingnessList;;
	"9" ) machinetags;;

	"h" ) myhelp;;
	"q" ) exit 0;;

	*   ) echo "Wrong selection";;
    esac
    mainMenu
    read -p "Please Select:" CHOOSE
    clear

done


