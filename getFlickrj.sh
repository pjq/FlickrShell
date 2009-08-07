#########################################################################
# Author: pengjianqing@gmail.com
# Created Time: Thu 06 Aug 2009 07:34:57 PM CST
# File Name: getFlickr.sh
# Description:Welcome to visit:www.impjq.net for more information. 
#This shell is used to get the flickrj java source code.
#flickrj is the flickr API of JAVA implementation.
#More information please visit:www.impjq.net
#########################################################################

#Download Base URL
#http://flickrj.cvs.sourceforge.net/viewvc/*checkout*/flickrj/api/src/com/aetrion/flickr/REST.java

#activity dir URL
#http://flickrj.cvs.sourceforge.net/viewvc/flickrj/api/src/com/aetrion/flickr/activity/?hideattic=1&pathrev=MAIN



TEMP=./temp
OUTDIR=./src/com/aetrion/flickr
JAVALIST=${TEMP}/java.list

[ -e "${TEMP}" ] || { echo "mkdir ${TEMP}"; mkdir ${TEMP}; }

getJavaList()
{
    echo "Get main.html"
    w3m -no-cookie "http://flickrj.cvs.sourceforge.net/viewvc/flickrj/api/src/com/aetrion/flickr/?hideattic=1&pathrev=MAIN">${TEMP}/main

#Get the main dir list
    echo "Get dir list"
    cat ${TEMP}/main|grep "^●"|cut -b -33|grep "/ "|sed 's/● //g'|sed 's/\///g'   >${TEMP}/dir.list

#Get the Javalist in the root dir：
    echo "Get java list in the root dir"
    grep java ${TEMP}/main|grep ".java"|cut -b -33|grep java|sed 's/● //g'|cut -d " " -f1 >${JAVALIST}

    

    echo "do For "
    for DIR in `cat ${TEMP}/dir.list`:
    do
        echo "DIR=${DIR}"
        [ -e ${OUTDIR}/${DIR} ] || { echo "mkdir -p ${OUTDIR}/${DIR}";mkdir -p ${OUTDIR}/${DIR}; }
        w3m -no-cookie "http://flickrj.cvs.sourceforge.net/viewvc/flickrj/api/src/com/aetrion/flickr/${DIR}?hideattic=1&pathrev=MAIN" >${TEMP}/${DIR}
        cat ${TEMP}/${DIR}|grep "^●"|cut -b -33|grep "/ "|sed 's/● //g'|sed 's/\///g' >${TEMP}/dir2.list

        grep java ${TEMP}/${DIR}|grep ".java"|cut -b -33|grep java|sed 's/● //g'|cut -d " " -f1|sed 's/^/'${DIR}'\//g' >>${JAVALIST}

        echo "cat ${TEMP}/dir2.list"
        cat ${TEMP}/dir2.list

        for DIR2 in `cat ${TEMP}/dir2.list`:
        do
            [ "${DIR2}" = ":" ] && continue
            echo "DIR2=${DIR}/${DIR2}"
            [ -e ${OUTDIR}/${DIR}/${DIR2} ] || { echo "mkdir -p ${OUTDIR}/${DIR}/${DIR2}";mkdir -p  ${OUTDIR}/${DIR}/${DIR2}; }
            TEMPDIR="${DIR}\/${DIR2}\/"
            echo TEMPDIR=${TEMPDIR}
            w3m -no-cookie "http://flickrj.cvs.sourceforge.net/viewvc/flickrj/api/src/com/aetrion/flickr/${DIR}/${DIR2}?hideattic=1&pathrev=MAIN" >${TEMP}/${DIR2}
            cat ${TEMP}/${DIR2}|grep "^●"|cut -b -33|grep "/ "|sed 's/● //g'|sed 's/\///g' >>${TEMP}/dir3.list

            grep java ${TEMP}/${DIR2}|grep ".java"|cut -b -33|grep java|sed 's/● //g'|cut -d " " -f1|sed 's/^/'${TEMPDIR}'/g' >>${JAVALIST}

        done
    done
}


getJavaFile()
{
    echo "Now Let's get the java files:"
    BASEURL="http://flickrj.cvs.sourceforge.net/viewvc/*checkout*/flickrj/api/src/com/aetrion/flickr/"

    for FILE in `cat ${TEMP}/java.list` :
    do
        echo "Get File:${FILE}"
	[  ${FILE}  = ":"  ]&& continue
        URL=${BASEURL}${FILE}
        echo URL=${URL}
        wget "${URL}" -O ${OUTDIR}/${FILE}


    done

}

showMenu()
{
    echo "Please choose:"
    echo "1.Get the Java list"
    echo "2.Get the Java File"
    echo "q.Exit"
}


#main function entry
showMenu
read -p "Please choose:" CHOOSE

while [ ${CHOOSE} != "q" ] 
do
    case "${CHOOSE}"  in
        "1"  ) getJavaList;;
        "2"  ) getJavaFile;;
        "q"  ) exit 0;;
        "*"  ) echo "Wrong choice.";;

    esac

showMenu
read -p "Please choose:" CHOOSE

done

