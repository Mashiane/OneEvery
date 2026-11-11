// variables for database table maintenance
var DB_REAL = "REAL";
var DB_INTEGER = "INTEGER";
var DB_BLOB = "BLOB";
var DB_TEXT = "TEXT";
var DB_FLOAT = "FLOAT";
var DB_NUMERIC = "NUMERIC";

function Ajax(URL, method, data, callback) {
	if (typeof(method) !== 'object') {
		var settings = new Object;
		if(!method || method === null || typeof(method) === 'undefined') method = "GET";
		settings.type = method.toUpperCase()
		if(!data || data === null || typeof(data) === 'undefined') data = "";
		settings.data = data;
		if (!callback) {
			settings.async = false;
			} else {
			settings.success = callback;
		settings.fail = callback}
	}
	return $.ajax(URL, settings);
}

function rgb2hex(rgb) {
      if (/^#[0-9A-F]{6}$/i.test(rgb)) { return rgb; }

      rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);

      if (rgb === null) { return "N/A"; }

      function hex(x) {
          return ("0" + parseInt(x).toString(16)).slice(-2);
      }

      return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
    }

function is_touch_device() {
      try {
        document.createEvent("TouchEvent");
        return true;
      } catch (e) {
        return false;
      }
    }
    if (is_touch_device()) {
      $('#nav-mobile').css({ overflow: 'auto'});
    }

function JQHasClass(id, cl) {
    var ret='false';
    if ($('#' + id).hasClass(cl)) {
        ret='true';
    }
    return ret;
}

function JQHide(id) {
    $('#' + id).hide();
}

function JQFocus(id) {
    $('#' + id).focus();
}

function JQSetAttribute(id, name, value) {
    $('#' + id).attr(name, value);
}

function JQGetAttribute(id, name) {
    return $('#' + id).attr(name);
}

function JQSetCSS(id, name, value) {
    $('#' + id).css(name, value);
}

function JQGetCSS(id, name) {
    return $('#' + id).css(name);
}

function JQRemoveCSS(id, name) {
    $('#' + id).css(name, '');
}

function JQRemoveAttribute(id, name) {
    $('#' + id).removeAttr(name);
}

function JQDisable(item, b) {
    $('#' + item).prop('disabled', b)
}

function JQSetChecked(item, b) {
    $('#' + item).prop('checked', b)
}

function JQEmpty(id) {
    $('#' + id).empty();
}

function JQRemove(id) {
    $('#' + id).remove();
}

function JQRemoveParent(id) {
    $('#' + id).parent().remove();
}

function JQAppendToMain(html) {
    $('main').append(html);
}

function JQAppendHTML(parentid, html) {
    $('#' + parentid).append(html);
}

function JQInsertHTMLAfter(parentid, html) {
    $(html).insertAfter($('#' + parentid));
}

function JQAppendTo(id, html) {
    $(html).appendTo($('#' + id));
}

function JQInsertHTMLBefore(parentid, html) {
    $(html).insertBefore($('#' + parentid));
}

function JQAddClass(id, cl) {
    $('#' + id).addClass(cl);
}

function JQRemoveClass(id, cl) {
    $('#' + id).removeClass(cl);
}
                        
function newGuid() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) { var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8); return v.toString(16); });
}

function getGuid() {
    if (window.name==='undefined') {
        return '';
    } else {
        var myUUID=window.name;
        if (myUUID==='') {
            myUUID=newGuid();
            window.name=myUUID;
        }
    }return myUUID;
}

function JQReplaceHTMLWith(id,html) {
    $('#' + id).replaceWith(html);
}



function JQSetValue(id,value) {
    $('#' + id).val(value);
}

function JQSetText(id,text) {
    $('#' + id).text(text);
}

function JQSetHTML(id,html) {
    $('#' + id).html(html);
}

function FileNameValid(str) {
	var s = str + '';
	s = s.replace(/\s+/gi, '-');
	return s.replace(/[^a-zA-Z0-9\-]/gi, '');
}

function ValidID(str) {
	var s = str + '';
	s = s.replace(/\s+/gi, '-');
	return s;
}

var isNull = function (obj) {
	return obj == null;
}

function NumericOnly(svalue) {
	var sout,
	lenvalue,
	i,
	spart;
	sout = "";
	lenvalue = Len(svalue);
	for (i = 1; i <= lenvalue; i++) {
		spart = Mid(svalue, i, 1);
		switch (true) {
			case ((spart) == "1"):
			sout = sout + spart;
			break;
			case ((spart) == "2"):
			sout = sout + spart;
			break;
			case ((spart) == "3"):
			sout = sout + spart;
			break;
			case ((spart) == "4"):
			sout = sout + spart;
			break;
			case ((spart) == "5"):
			sout = sout + spart;
			break;
			case ((spart) == "6"):
			sout = sout + spart;
			break;
			case ((spart) == "7"):
			sout = sout + spart;
			break;
			case ((spart) == "8"):
			sout = sout + spart;
			break;
			case ((spart) == "9"):
			sout = sout + spart;
			break;
			case ((spart) == "0"):
			sout = sout + spart;
			break;
			case ((spart) == "-"):
			sout = sout + spart;
		}
	}
	return sout;
}

function NewId() {
	var dc = new Date();
	var id = new String(dc.getTime());
	id += new String(getRandomInt(0, 100));
	return id;
}

function Replace(str,fnd,rpl) {
    var regex;
	var cnt = null;
	var st = null;
	var cmp;
    if(st===null||st===""||st<0){st=1;}
    st-=1;
    if(cnt===null||cnt===""||cnt<0){cnt=0;}
    if(st>=0){str=str.substr(st,str.length);}
    fnd=fnd.replace(/([\$\^\[\(\)\|\*\+\?\.\\])/g,'\\$1');
    var opt='';
    cmp=cmp+"";
    if(cmp==='1'){opt='i';}
    if(cnt>0) {
        regex=new RegExp(fnd,opt);
        for(var i=0;i<cnt;i++) {
            str=str.replace(regex,rpl);
		}
		}else{
        opt+='g';
        regex=new RegExp(fnd,opt);
        str=str.replace(regex,rpl);
	}
    return str;
}

function IsNumeric(sValue) {
	return!isNaN(sValue);
}

function FixParent(sField, sValue) {
    var sout;
    if (IsNumeric(sValue) == true) {
        sout = sField + "-" + sValue;
		return sout;
		} else {
        return sValue;
	}
}

function getRandomInt(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function NewDate() {
	return new Date();
}


function Right(str, n){
    if (n <= 0)
	return "";
    else if (n > String(str).length)
	return str;
    else {
		var iLen = String(str).length;
		return String(str).substring(iLen, iLen - n);
	}
}

function Left(str, n) {
	var s = str + '';
	var iLen = s.length;
	if (n <= 0) {
		return "";
		} else if (n >= iLen) {
		return str;
		} else {
		return s.substr(0, n);
	}
}

function Mid(strMid, intBeg, intEnd) {
	if (strMid === null || strMid === '' || intBeg < 0) {
		return '';
	}
	intBeg -= 1;
	if (intEnd === null || intEnd === '') {
		return strMid.substr(intBeg);
		} else {
		return strMid.substr(intBeg, intEnd);
	}
}

function CStr(str) {
	var s = str;
	s = s.toString();
	return s;
}

function LCase(str) {
	return str.toLowerCase();
}

function InStr(searchStr, searchFor) {
	if (Len(searchStr) = 0) {
		return 0;
	}
	var s = searchStr;
	var s1 = searchFor;
	s = s.toString();
	s1 = s1.toString();
	s = LCase(s);
	s1 = LCase(s1);
	var loc = s.indexOf(s1) + 1;
	return loc;
}

function InStrRev(srchStr, fndStr, start, cmp) {
	if (!fndStr || fndStr === null) {
		fndStr = "";
	}
	if (!cmp) {
		cmp = 0;
	}
	srchStr.toString();
	if (cmp == 1) {
		srchStr = srchStr.toLowerCase();
		fndStr = fndStr.toLowerCase();
	}
	if (!start || !IsNumeric(start)) {
		start = -1;
	}
	if (start > -1) {
		srchStr = srchStr.substr(0, start);
	}
	var loc;
	if (fndStr === "") {
		loc = srchStr.length;
		} else {
		loc = srchStr.lastIndexOf(fndStr) + 1;
	}
	return loc;
}

function Len(str) {
	str += '';
	return str.length;
}

function Chr(num) {
	var res = String.fromCharCode(num);
	return res;
}

function Asc(str) {
	return str.charCodeAt(0);
}

function FM() {
	return Chr(254);
}

function VM() {
	return Chr(253);
}

function Quote() {
	return Chr(34);
}

function InQuotes(value) {
	var res = Quote + value + Quote
	return res;
}

function Form2Json(form) {
	// convert form name value attributes to json
	var array = $(form).serializeArray();
	var json = {};
	$.each(array, function () {
		if (typeof json[this.name] == 'undefined') {
			json[this.name] = this.value || '';
			} else {
			json[this.name] += "," + this.value;
		}
	});
	return json;
}

function MakeMoney(nStr) {
	nStr = ProperAmount(nStr);
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}

function isValidDate(dateStr) {
	if (Len(dateStr) = 0) {
		return "0"
	}
	var msg = "";
	// Checks for the following valid date formats:
	// MM/DD/YY   MM/DD/YYYY   MM-DD-YY   MM-DD-YYYY
	// Also separates date into month, day, and year variables
	
	// To require a 2 & 4 digit year entry, use this line instead:
	//var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{2}|\d{4})$/;
	// To require a 4 digit year entry, use this line instead:
	var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{4})$/;
	
	var matchArray = dateStr.match(datePat); // is the format ok?
	if (matchArray == null) {
		return "0";
	}
	
	month = matchArray[1]; // parse date into variables
	day = matchArray[3];
	year = matchArray[4];
	
	if (month < 1 || month > 12) { // check month range
		msg = "Month must be between 1 and 12.";
		return "0";
	}
	
	if (day < 1 || day > 31) {
		msg = "Day must be between 1 and 31.";
		return "0";
	}
	
	if ((month == 4 || month == 6 || month == 9 || month == 11) && day == 31) {
		msg = "Month " + month + " doesn't have 31 days!";
		return "0";
	}
	
	if (month == 2) { // check for february 29th
		var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
		if (day > 29 || (day == 29 && !isleap)) {
			msg = "February " + year + " doesn't have " + day + " days!";
			return "0";
		}
	}
	
	if (day.charAt(0) == '0')
	day = day.charAt(1);
	
	//Incase you need the value in CCYYMMDD format in your server program
	//msg = (parseInt(year,10) * 10000) + (parseInt(month,10) * 100) + parseInt(day,10);
	
	return msg; // date is valid
}

function MvRest(svalue, iposition, delimiter) {
	var mvalues,
	tvalues,
	xvalue,
	x,
	y,
	resultx;
	var lendelim;
	lendelim = Len(delimiter);
	mvalues = Split(svalue, delimiter);
	tvalues = mvalues.length - 1;
	iposition = iposition - 1;
	if (iposition <= -1) {
		xvalue = mvalues[tvalues];
		return xvalue;
	}
	
	if (iposition > tvalues) {
		return "";
	}
	
	resultx = "";
	x = iposition + 1;
	for (y = x; y <= tvalues; y++) {
		xvalue = mvalues[y];
		resultx = resultx + xvalue + delimiter;
	}
	
	resultx = Left(resultx, Len(resultx) - lendelim);
	return resultx;
}

function Age(birthDate) {
	birthDate = Replace(birthDate, ".", "-");
	var yyyy = MvField(birthDate,1, "-");
	var mmmm = MvField(birthDate,2, "-");
	var dddd = MvField(birthDate,3, "-");
	var agex = getAge(mmmm,dddd,yyyy);
	agex = MvField(agex,1, ".");
	return agex;
}

function getAge(birthMonth, birthDay, birthYear) {
	todayDate = new Date();
	todayYear = todayDate.getFullYear();
	todayMonth = todayDate.getMonth();
	todayDay = todayDate.getDate();
	age = todayYear - birthYear;
	
	if (todayMonth < birthMonth - 1) {
		age--;
	}
	
	if (birthMonth - 1 == todayMonth && todayDay < birthDay) {
		age--;
	}
	return age;
}

function MvSum(strvalues, delim) {
	var dtot,
	i;
	dtot = 0;
	var spvalues;
	spvalues = Split(strvalues, delim);
	var dlen;
	dlen = spvalues.length - 1;
	for (i = 0; i <= dlen; i++) {
		dtot = parseFloat(dtot) + parseFloat(spvalues[i]);
	}
	dtot = Round(dtot, 2);
	return dtot;
}

function InSingleQuote(strV) {
	return "'" + strV + "'";
}

function MonthNumber(strM) {
	strM = Left(strM,3);
	strM = LCase(strM);
	switch (true) {
		case ((strM) == "jan"):
		return 1;
		break;
		case ((strM) == "feb"):
		return 2;
		break;
		case ((strM) == "mar"):
		return 3;
		break;
		case ((strM) == "apr"):
		return 4;
		break;
		case ((strM) == "may"):
		return 5;
		break;
		case ((strM) == "jun"):
		return 6;
		break;
		case ((strM) == "jul"):
		return 7;
		break;
		case ((strM) == "aug"):
		return 8;
		break;
		case ((strM) == "sep"):
		return 9;
		break;
		case ((strM) == "oct"):
		return 10;
		break;
		case ((strM) == "nov"):
		return 11;
		break;
		case ((strM) == "dec"):
		return 12;
	}
}

function Split(svalue, sdelimiter) {
	svalue += '';
	sdelimiter += '';
	return svalue.split(sdelimiter);
}

function Round(n,d) {
	if (!d||d===null||d===""){
		d=0;
	}
    d = Math.floor(d);
	d = d<1?0:d;
	d=Math.pow(10,d);
	var result=Math.round(n*d)/d;
	return result;
}

function RemoveDelim(strmv, delim) {
	var lendelim,
	rightpart,
	strout;
	lendelim = Len(delim);
	rightpart = Right(strmv, lendelim);
	strout = strmv;
	if (rightpart == delim) {
		strout = Left(strmv, Len(strmv) - lendelim);
	}
	return strout;
}

function SaveSetting(key, value) {
	key = CStr(key);
	key = Trim(key);
	value = CStr(value);
	value = Trim(value);
	localStorage.setItem(key, value);
}

function GetSetting(key) {
	key = CStr(key);
	key = Trim(key);
	var svalue;
	svalue = localStorage.getItem(key);
	if (isNull(svalue) == true) {
		svalue = "";
	}
	svalue = CStr(svalue);
	svalue = Trim(svalue);
	return svalue;
}

function MvRemoteItem(strmv, sremove, delim) {
	sremove = LCase(sremove);
	var sout,
	lendelim;
	sout = "";
	var spv = Split(strmv, delim);
	var stot,
	scnt,
	sitem;
	lendelim = Len(delim);
	stot = spv.length - 1;
	for (scnt = 0; scnt <= stot; scnt++) {
		sitem = LCase(spv(scnt));
		if (sitem != sremove) {
			sout = sout + spv(scnt) + delim;
		}
	}
	sout = Left(sout, Len(sout) - lendelim);
	return sout;
}

function MvSearch(searchvalues, strsearch, delim) {
	if (Len(searchvalues) == 0) {
		return -1;
	}
	var spvalues,
	i,
	itot,
	ivalue;
	spvalues = Split(searchvalues, delim);
	strsearch = LCase(strsearch);
	itot = spvalues.length - 1;
	for (i = 0; i <= itot; i++) {
		ivalue = spvalues[i];
		ivalue = LCase(ivalue);
		if (ivalue == strsearch) {
			return i;
		}
	}
	return -1;
}

function UCase(str) {
	return str.toUpperCase();
}

function Trim(str) {
	return str.trim();
}

function ProperAmount(svalue) {
	svalue = Replace(svalue, ",", "");
	svalue = svalue.toFixed(2);
	return svalue;
}

String.format = function() {
    // The string containing the format items (e.g. "{0}")
    // will and always has to be the first argument.
	//var link = String.format('<a href="{0}/{1}/{2}" title="{3}">{3}</a>'
    var theString = arguments[0];
    
    // start with the second argument (i = 1)
    for (var i = 1; i < arguments.length; i++) {
        // "gm" = RegEx options for Global search (more than one instance)
        // and for Multiline search
        var regEx = new RegExp("\\{" + (i - 1) + "\\}", "gm");
        theString = theString.replace(regEx, arguments[i]);
	}    
    return theString;
}

function MvField(svalue, iposition, delimiter) {
	var mvalues,
	tvalues,
	xvalue;
	mvalues = Split(svalue, delimiter);
	tvalues = mvalues.length - 1;
	iposition = iposition - 1;
	if (iposition <= -1) {
		xvalue = mvalues[tvalues];
		return xvalue;
	}
	if (iposition > tvalues) {
		return "";
	}
	xvalue = mvalues[iposition];
	return xvalue;
}

function email(t, subject, body) {
	location = "mailto:" + encodeURI(t) + "?subject=" + encodeURI(subject) + "&body=" + encodeURI(body);
}

function phone(tel) {
	location = "tel:" + tel;
}

function skype(tel) {
	location = "skype:" + tel;
}

function sms(tel, body) {
	location = "sms:" + tel + "?body=" + encodeURL(body);
}

function Alphabets(svalue) {
	var sout,
	slen,
	i,
	schar,
	isnum;
	sout = "";
	slen = Len(svalue);
	schar = Mid(svalue, slen, 1);
	isnum = IsNumeric(schar);
	do {
		if (isnum == false)
		break;
		svalue = Left(svalue, slen - 1);
		slen = Len(svalue);
		schar = Mid(svalue, slen, 1);
		isnum = IsNumeric(schar);
	} while (0 < 1);
	return svalue;
}

function MonthName(svalue) {
	var month = new Array();
	month[1] = "January";
	month[2] = "February";
	month[3] = "March";
	month[4] = "April";
	month[5] = "May";
	month[6] = "June";
	month[7] = "July";
	month[8] = "August";
	month[9] = "September";
	month[10] = "October";
	month[11] = "November";
	month[12] = "December";
	return month(svalue);
}

function CharAt(svalue, pos) {
	return svalue.charAt(pos - 1)
}

function CharCodeAt(svalue, pos) {
	return svalue.charCodeAt(pos - 1)
}

function DateIconv() {
	var x = new Date();
    x = Number(x)
	return x;
}

function ThisYear() {
	var x = new Date();
	x = x.getFullYear();
	return x;
}

function Today() {
	var currentTime = new Date();
	var currentMonth = currentTime.getMonth();
	var currentDate = currentTime.getDate();
	var currentYear = currentTime.getFullYear();
	var tday = currentYear + "-" + currentmonth + "-" & currentDate;
	return tday;
}

function ThisTime() {
	var x = new Date();
	x = x.getTime(); 
	return x;
}

function ThisWeekDay() {
	var x = new Date();
	x = x.getDay() + 1;
	return x;
}

function ThisMonth() {
	var x = new Date();
	x = x.getMonth() + 1;
	return x;
}

function ThisMonthName() {
	var x = new Date();
	x = x.getMonth() + 1
	x = MonthName(x); 
	return x;
}	

function ThisWeekDayName() {
	var x = new Date();
	var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
	x = days[x.getDay()];
	return x;
}	

function Concat(s1, s2) {
	var s = s1.concat(s2);
	return s;
}

function IsArray(myArray) {
    return myArray.constructor.toString().indexOf("Array") > -1;
}

function IsDate(myDate) {
    return myDate.constructor.toString().indexOf("Date") > -1;
}

function CInt(value) {
	var x = Number(value);
	return x;
}

Date.prototype.adjust = function(part, amount){
	//var d = new Date();
	//d.adjust('hour', -10);
	part = part.toLowerCase();
	
	var map = { 
		years: 'FullYear', months: 'Month', weeks: 'Hours', days: 'Hours', hours: 'Hours', 
		minutes: 'Minutes', seconds: 'Seconds', milliseconds: 'Milliseconds',
		utcyears: 'UTCFullYear', utcmonths: 'UTCMonth', weeks: 'UTCHours', utcdays: 'UTCHours', 
		utchours: 'UTCHours', utcminutes: 'UTCMinutes', utcseconds: 'UTCSeconds', utcmilliseconds: 'UTCMilliseconds'
	},
	mapPart = map[part];
	
	if(part == 'weeks' || part == 'utcweeks')
	amount *= 168;
	if(part == 'days' || part == 'utcdays')
	amount *= 24;
	
	this['set'+ mapPart]( this['get'+ mapPart]() + amount );
	
	return this;
}

Date.prototype.diff = function(date2, parts){
	//d1.diff(d2,'weeks');
	//d1.diff(d2,['months','weeks','days']);
	var d1 = new Date(this.getTime()),
	d2 = new Date(date2.getTime()),
	pm = d1 <= d2? 1 : -1,
	result = { },
	factors = { weeks: (1000*60*60*24*7), days: (1000*60*60*24), hours: (1000*60*60), minutes: (1000*60), seconds: 1000, milliseconds: 1 };
	
	if(parts === undefined)
	parts = ['years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds', 'milliseconds'];
	else if(typeof(parts) == "string")
	parts = [parts];
	
	for(var i=0, l=parts.length; i<l; i++){
		var k = parts[i];
		result[k] = 0;
		
		if(factors[k] === undefined){
			inaWhile: while( true ){
				d2.adjust(k, -1*pm);
				if( (pm === 1 && d1 > d2) || (pm === -1 && d1 < d2)){
					d2.adjust(k, 1*pm);
					break inaWhile;
				}
				result[k]++;
			}
		}
		else{
			var tmpDiff = Math.abs(d2.getTime() - d1.getTime());
			result[k] = Math.floor(tmpDiff / factors[k]);
			d2.adjust(k, result[k]*-1*pm);
		}
		result[k] *= pm;
	}
	
	if(parts.length == 1)
	return result[parts[0]];
	return result;
}

function DateAdd(ItemType, DateToWorkOn, ValueToBeAdded)
{
    switch (ItemType)
    {
        //date portion         
        case 'd': //add days
		DateToWorkOn.setDate(DateToWorkOn.getDate() + ValueToBeAdded)
		break;
        case 'm': //add months
		DateToWorkOn.setMonth(DateToWorkOn.getMonth() + ValueToBeAdded)
		break;
        case 'y': //add years
		DateToWorkOn.setYear(DateToWorkOn.getFullYear() + ValueToBeAdded)
		break;
        //time portion         
        case 'h': //add days
		DateToWorkOn.setHours(DateToWorkOn.getHours() + ValueToBeAdded)
		break;
        case 'n': //add minutes
		DateToWorkOn.setMinutes(DateToWorkOn.getMinutes() + ValueToBeAdded)
		break;
        case 's': //add seconds
		DateToWorkOn.setSeconds(DateToWorkOn.getSeconds() + ValueToBeAdded)
		break;
	}
    return DateToWorkOn;
}

String.prototype.format = String.prototype.f = function() {
	//'Your balance is {0} USD'.format(77.7) 
    var s = this,
	i = arguments.length;
	
    while (i--) {
        s = s.replace(new RegExp('\\{' + i + '\\}', 'gm'), arguments[i]);
	}
    return s;
};

String.prototype.endsWith = function (suffix) {
	return (this.substr(this.length - suffix.length) === suffix);
}

String.prototype.startsWith = function(prefix) {
	return (this.substr(0, prefix.length) === prefix);
}

var format = function (str, col) {
	// format('Tel {0}', 'mine');
    col = typeof col === 'object' ? col : Array.prototype.slice.call(arguments, 1);
	
    return str.replace(/\{\{|\}\}|\{(\w+)\}/g, function (m, n) {
        if (m == "{{") { return "{"; }
        if (m == "}}") { return "}"; }
        return col[n];
	});
};



function SqlOpenDb(shortName, version, displayName, maxSize) {
	// code to open the database and returns a variable, one can open different
	// databases, database size is 1MB, increase dbsize to <= 5
    var db, dbsize = 1;
    try {
        if (!window.openDatabase) {
            return 0;
	    } else {
        if (typeof (shortName) === 'undefined') {
            return 0;
		}
        if (typeof (version) === 'undefined') version = "";
        if (typeof (displayName) === 'undefined') displayName = shortName;
        if (typeof (maxSize) === 'undefined') maxSize = dbsize * (1024 * 1024);
        db = openDatabase(shortName, version, displayName, maxSize);
		}
	} catch (e) {
        return 0;
	}
    return db;
}

function SqlExecute(db, sqlList) {
	// code to execute array commands to the database
	// db is the variable holding the database reference
	// sqlList is an array of commands to execute
    db.transaction(function (transaction) {
		// loop through each sql command with success and error result
        for (var i = 0; i < sqlList.length; i++) {
            // create a new scope that holds sql for the error message, if needed
            (function (tx, sql) {
                if (typeof (sql) === 'string') sql = [sql];
                if (typeof (sql[1]) === 'string') sql[1] = [sql[1]];
                var args = (typeof (sql[1]) === 'object') ? sql.splice(1, 1)[0] : [];
                var sql_return = sql[1] || function () {};
                var sql_error = sql[2] || function () {};
				tx.executeSql(sql[0], args, sql_return, sql_error);
			}(transaction, sqlList[i]));
		}
	});
}

function SqlCreateTable(db, TableName, FieldsAndTypes, PrimaryKey, AutoIncrement) {
	// code to create a table in the websql database
	// fieldsandtypes is a json object
	// autoincrement is the field name to autoincrement
    var sb = "(";
    for (item in FieldsAndTypes) {
        sb += "[" + item + "] " + FieldsAndTypes[item];
        if (item == PrimaryKey) {
            sb += " NOT NULL PRIMARY KEY";
		}
        if (item == AutoIncrement) {
            sb += " AUTOINCREMENT";
		}
        sb += ", ";
	}
    sb = Left(sb, (Len(sb) - 2));
    sb += ")";
    sb = "CREATE TABLE IF NOT EXISTS [" + TableName + "] " + sb + ";";
    return Execute(db, sb);
}

function SqlAddColumns(db, TableName, FieldsAndTypes) {
	// code to add columns to the table in the database
    var sqlColumn = [];
	var strCol = '';
	//define fields to be added
    for (item in FieldsAndTypes) {
		strCol = "ALTER TABLE [" + TableName + "] ADD COLUMN [" + item + "] " + FieldsAndTypes[item] + ';';
		sqlColumn.push(strCol); 
	}
    SqlExecute(db, sqlColumn);
}

function SqlInsertRecord(db, tblName, tblRecord) {
	// code to insert a record into the database
	// fields are passed as parameters
    var qry, flds = "", vals = "", avals = [];
	for (var key in tblRecord) {
		flds += "[" + key + "],";
		vals += "?,";
		avals.push(tblRecord[key]);
	}
	flds = Left(flds, Len(flds) - 1);
    vals = Left(vals, Len(vals) - 1);
    qry = "INSERT INTO [" + tblName + "] (" + flds + ") VALUES (" + vals + ");";
    return Execute(db, qry, avals);
}

function SqlCreateIndexes(db, TableName, Indexes) {
	// code to create table index in the database
    var sb, idef, sqlCreateIdx = [], idxname, spidx, idxtot, idxcnt, idx;
    spidx = Split(Indexes, ",");
    idxtot = spidx.length - 1;
    //define indexes to be created
    for (idxcnt = 0; idxcnt <= idxtot; idxcnt++) {
        idx = spidx(idxcnt);
        idxname = TableName + "_" + idx;
        idef = "CREATE INDEX IF NOT EXISTS [" + idxname + "] ON [" + TableName + "] ([" + idx + "]);";
        sqlCreateIdx[idxcnt] = idef;
	}
    SqlExecute(db, sqlCreateIdx);
}

function SqlUpdateRecordWhere(db, tblName, tblRecord, tblWhere) {
	// code to update a record on a database
	// tblRecord and tblWhere should be objects
    var qry = "", vals = "", wvals = "", avals = [];
    for (item in tblRecord) {
        vals += "[" + item + "] = ?,";
		avals.push(tblRecord[item]);
	}
    for (item in tblWhere) {
        wvals += "[" + item + "] = ? AND ";
		avals.push(tblWhere[item]);
	}
    vals = Left(vals, Len(vals) - 1);
    wvals = Left(wvals, Len(wvals) - 5);
    qry = "UPDATE [" + tblName + "] SET " + vals + " WHERE " + wvals + ";";
    return Execute(db, qry, avals);
}

function SqlGetRecordWhere(db, tblName, tblWhere) {
	// code to get a record from database using a where clause
	// tblWhere should be objects
    var qry = "", vals = "", avals = [];
    for (item in tblWhere) {
        vals += "[" + item + "] = ? AND ";
		avals.push(tblWhere[item]);
	}
    vals = Left(vals, Len(vals) - 5);
    qry = "SELECT * FROM [" + tblName + "] WHERE " + vals + ";";
    return Execute(db, qry, avals);
}

function SqlUpdateRecords(db, tblName, tblRecord) {
	// update all records of the table
	// using parameter values
    var vals = "", avals = [];
    for (item in tblRecord) {
        vals = vals + "[" + item + "] = ?,";
		avals.push(tblRecord[item]);
	}
    vals = Left(vals, Len(vals) - 1);
    var qry = "UPDATE [" + tblName + "] SET " + vals + ";";
    return Execute(db, qry, avals);
}

function Execute(db, qry, args){
	// execute a query against the database using defer
	if (typeof (args) === 'undefined') args = [];
    return $.Deferred(function (d) {
        db.transaction(function (tx) {
            tx.executeSql(qry, args, successWrapper(d), failureWrapper(d));
            });
        });
};

function SqlGetRecords(db, TableName, PrimaryKey) {
	// return all records from a table ordered by primary key
    var qry = "SELECT * FROM [" + TableName + "] ORDER BY [" + PrimaryKey +"]";
    return Execute(db, qry);
};

function SqlGetDistinctField(db, TableName, FldName) {
	// return distinct records from a table
    var qry = "SELECT DISTINCT [" + FldName + "] FROM [" + TableName + "] ORDER BY [" + FldName +"]";
    return Execute(db, qry);
};

function successWrapper(d) {
	// when sql query succeeds
    return (function (tx, data) {
        d.resolve(data)
    })
};

function failureWrapper(d) {
	// when sql query fails
    return (function (tx, error) {
    d.reject(error)
    })
};

function ResultSetToJSON(results, PrimaryKey) {
    // process data returned by successWrapper;
	// return it as a json object using primary key as key
    var Records = {};
    var len = results.rows.length - 1, priKey, i, row;
    // loop through each row
    for (i = 0; i <= len; i++) {
		// get the row
        row = results.rows.item(i);
		// get the primary key
        priKey = row[PrimaryKey];
		// cleanse the primary key
		priKey = priKey.split(' ').join('-');
		// set row to object using primary key
        Records[priKey] = row;
    }
    return Records;
}

function SqlDeleteRecordWhere(db, tblName, tblWhere) {
    // delete a record from a table using a where clause
	// pass the where fields as parameters
    var qry, wvals = "", avals = [];
    for (item in tblWhere) {
        wvals += "[" + item + "] = ? AND ";
		avals.push(tblWhere[item]);
	}
	// remove last ' AND '
    wvals = Left(wvals, Len(wvals) - 5);
    qry = "DELETE FROM [" + tblName + "] WHERE " + wvals + ";";
    return Execute(db, qry, avals);
};