/*****************************************************************************
 * base64enc.js
 *
 * A JavaScript implementation of the RFC 2045 base64 encoding.  Encodes only
 * typeable characters.
 *
 * Public functions:  String base64encode(str)
 *
 * Copyright (C) 2000 Blackboard, Inc.
 *****************************************************************************/

// To convert value to base64 alphabet
var sBase64Alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

// Converts the 3 character string to 4 character base64 encoded
function base64encode_quantum(str) {
    var strLen = str.length;
    // Create a 4 integer array for the 3 character "quantum"
    var aQuantum = new Array(4);
    // Read in the first, second, and third values
    var nFirst = (strLen > 0) ? str.charCodeAt(0) : 0;
    var nSecond = (strLen > 1) ? str.charCodeAt(1) : 0;
    var nThird = (strLen > 2) ? str.charCodeAt(2) : 0;

    // Convert 4 base64 values from the 3 character values
    aQuantum[0] = nFirst >> 2;
    aQuantum[1] = ((nFirst & 3) << 4) + (nSecond >> 4);
    aQuantum[2] = ((nSecond & 15) << 2) + (nThird >> 6);
    aQuantum[3] = nThird & 63;

    // Adjust for the padding in case there were not enough characters in the input str
    if (strLen == 1) {
        aQuantum[2] = 64; // pad
        aQuantum[3] = 64; // pad
    } else if (strLen == 2) {
        aQuantum[3] = 64; // pad
    }

    // Create the base64 string
    var sRet = "";
    for (var i = 0; i < 4; i++) {
        sRet += sBase64Alpha.charAt(aQuantum[i]);
    }
    // Return the result
    return sRet;
}


// Converts the input string into a base64 string
function base64encode(str) {
    // Break up into 3 character quantums and convert
    var i, nFrom, nTo;
    var sRet = "";
    for (i = 0; i < str.length; i += 3) {
        nFrom = i;
        nTo = (i + 3 < str.length) ? i + 3 : str.length;
        sRet += base64encode_quantum(str.substring(nFrom, nTo));
    }
    return sRet;
}

/*
 * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
 * Digest Algorithm, as defined in RFC 1321.
 * Version 2.1 Copyright (C) Paul Johnston 1999 - 2002.
 * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
 * Distributed under the BSD License
 * See http://pajhome.org.uk/crypt/md5 for more info.
 */

/*
 * Configurable variables. You may need to tweak these to be compatible with
 * the server-side, but the defaults work in most cases.
 */
var hexcase = 1; /* hex output format. 0 - lowercase; 1 - uppercase        */
var b64pad = "="; /* base-64 pad character. "=" for strict RFC compliance   */
var chrsz = 16; /* bits per input character. 8 - ASCII; 16 - Unicode      */

/*
 * These are the functions you'll usually want to call
 * They take string arguments and return either hex or base-64 encoded strings
 */
function calcMD5(s) {
    return binl2hex(core_md5(str2binl(s), s.length * chrsz)); }

function b64_md5(s) {
    return binl2b64(core_md5(str2binl(s), s.length * chrsz)); }

function b64_unicode(s) {
    return binl2b64(str2binl(s), s.length * chrsz); }

function str_md5(s) {
    return binl2str(core_md5(str2binl(s), s.length * chrsz)); }

function hex_hmac_md5(key, data) {
    return binl2hex(core_hmac_md5(key, data)); }

function b64_hmac_md5(key, data) {
    return binl2b64(core_hmac_md5(key, data)); }

function str_hmac_md5(key, data) {
    return binl2str(core_hmac_md5(key, data)); }

/*
 * Perform a simple self-test to see if the VM is working
 */
function md5_vm_test() {
    return hex_md5("abc") == "900150983cd24fb0d6963f7d28e17f72";
}

/*
 * Calculate the MD5 of an array of little-endian words, and a bit length
 */
function core_md5(x, len) {
    /* append padding */
    x[len >> 5] |= 0x80 << ((len) % 32);
    x[(((len + 64) >>> 9) << 4) + 14] = len;

    var a = 1732584193;
    var b = -271733879;
    var c = -1732584194;
    var d = 271733878;

    for (var i = 0; i < x.length; i += 16) {
        var olda = a;
        var oldb = b;
        var oldc = c;
        var oldd = d;

        a = md5_ff(a, b, c, d, x[i + 0], 7, -680876936);
        d = md5_ff(d, a, b, c, x[i + 1], 12, -389564586);
        c = md5_ff(c, d, a, b, x[i + 2], 17, 606105819);
        b = md5_ff(b, c, d, a, x[i + 3], 22, -1044525330);
        a = md5_ff(a, b, c, d, x[i + 4], 7, -176418897);
        d = md5_ff(d, a, b, c, x[i + 5], 12, 1200080426);
        c = md5_ff(c, d, a, b, x[i + 6], 17, -1473231341);
        b = md5_ff(b, c, d, a, x[i + 7], 22, -45705983);
        a = md5_ff(a, b, c, d, x[i + 8], 7, 1770035416);
        d = md5_ff(d, a, b, c, x[i + 9], 12, -1958414417);
        c = md5_ff(c, d, a, b, x[i + 10], 17, -42063);
        b = md5_ff(b, c, d, a, x[i + 11], 22, -1990404162);
        a = md5_ff(a, b, c, d, x[i + 12], 7, 1804603682);
        d = md5_ff(d, a, b, c, x[i + 13], 12, -40341101);
        c = md5_ff(c, d, a, b, x[i + 14], 17, -1502002290);
        b = md5_ff(b, c, d, a, x[i + 15], 22, 1236535329);

        a = md5_gg(a, b, c, d, x[i + 1], 5, -165796510);
        d = md5_gg(d, a, b, c, x[i + 6], 9, -1069501632);
        c = md5_gg(c, d, a, b, x[i + 11], 14, 643717713);
        b = md5_gg(b, c, d, a, x[i + 0], 20, -373897302);
        a = md5_gg(a, b, c, d, x[i + 5], 5, -701558691);
        d = md5_gg(d, a, b, c, x[i + 10], 9, 38016083);
        c = md5_gg(c, d, a, b, x[i + 15], 14, -660478335);
        b = md5_gg(b, c, d, a, x[i + 4], 20, -405537848);
        a = md5_gg(a, b, c, d, x[i + 9], 5, 568446438);
        d = md5_gg(d, a, b, c, x[i + 14], 9, -1019803690);
        c = md5_gg(c, d, a, b, x[i + 3], 14, -187363961);
        b = md5_gg(b, c, d, a, x[i + 8], 20, 1163531501);
        a = md5_gg(a, b, c, d, x[i + 13], 5, -1444681467);
        d = md5_gg(d, a, b, c, x[i + 2], 9, -51403784);
        c = md5_gg(c, d, a, b, x[i + 7], 14, 1735328473);
        b = md5_gg(b, c, d, a, x[i + 12], 20, -1926607734);

        a = md5_hh(a, b, c, d, x[i + 5], 4, -378558);
        d = md5_hh(d, a, b, c, x[i + 8], 11, -2022574463);
        c = md5_hh(c, d, a, b, x[i + 11], 16, 1839030562);
        b = md5_hh(b, c, d, a, x[i + 14], 23, -35309556);
        a = md5_hh(a, b, c, d, x[i + 1], 4, -1530992060);
        d = md5_hh(d, a, b, c, x[i + 4], 11, 1272893353);
        c = md5_hh(c, d, a, b, x[i + 7], 16, -155497632);
        b = md5_hh(b, c, d, a, x[i + 10], 23, -1094730640);
        a = md5_hh(a, b, c, d, x[i + 13], 4, 681279174);
        d = md5_hh(d, a, b, c, x[i + 0], 11, -358537222);
        c = md5_hh(c, d, a, b, x[i + 3], 16, -722521979);
        b = md5_hh(b, c, d, a, x[i + 6], 23, 76029189);
        a = md5_hh(a, b, c, d, x[i + 9], 4, -640364487);
        d = md5_hh(d, a, b, c, x[i + 12], 11, -421815835);
        c = md5_hh(c, d, a, b, x[i + 15], 16, 530742520);
        b = md5_hh(b, c, d, a, x[i + 2], 23, -995338651);

        a = md5_ii(a, b, c, d, x[i + 0], 6, -198630844);
        d = md5_ii(d, a, b, c, x[i + 7], 10, 1126891415);
        c = md5_ii(c, d, a, b, x[i + 14], 15, -1416354905);
        b = md5_ii(b, c, d, a, x[i + 5], 21, -57434055);
        a = md5_ii(a, b, c, d, x[i + 12], 6, 1700485571);
        d = md5_ii(d, a, b, c, x[i + 3], 10, -1894986606);
        c = md5_ii(c, d, a, b, x[i + 10], 15, -1051523);
        b = md5_ii(b, c, d, a, x[i + 1], 21, -2054922799);
        a = md5_ii(a, b, c, d, x[i + 8], 6, 1873313359);
        d = md5_ii(d, a, b, c, x[i + 15], 10, -30611744);
        c = md5_ii(c, d, a, b, x[i + 6], 15, -1560198380);
        b = md5_ii(b, c, d, a, x[i + 13], 21, 1309151649);
        a = md5_ii(a, b, c, d, x[i + 4], 6, -145523070);
        d = md5_ii(d, a, b, c, x[i + 11], 10, -1120210379);
        c = md5_ii(c, d, a, b, x[i + 2], 15, 718787259);
        b = md5_ii(b, c, d, a, x[i + 9], 21, -343485551);

        a = safe_add(a, olda);
        b = safe_add(b, oldb);
        c = safe_add(c, oldc);
        d = safe_add(d, oldd);
    }
    return Array(a, b, c, d);

}

/*
 * These functions implement the four basic operations the algorithm uses.
 */
function md5_cmn(q, a, b, x, s, t) {
    return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b);
}

function md5_ff(a, b, c, d, x, s, t) {
    return md5_cmn((b & c) | ((~b) & d), a, b, x, s, t);
}

function md5_gg(a, b, c, d, x, s, t) {
    return md5_cmn((b & d) | (c & (~d)), a, b, x, s, t);
}

function md5_hh(a, b, c, d, x, s, t) {
    return md5_cmn(b ^ c ^ d, a, b, x, s, t);
}

function md5_ii(a, b, c, d, x, s, t) {
    return md5_cmn(c ^ (b | (~d)), a, b, x, s, t);
}

/*
 * Calculate the HMAC-MD5, of a key and some data
 */
function core_hmac_md5(key, data) {
    var bkey = str2binl(key);
    if (bkey.length > 16) bkey = core_md5(bkey, key.length * chrsz);

    var ipad = Array(16),
        opad = Array(16);
    for (var i = 0; i < 16; i++) {
        ipad[i] = bkey[i] ^ 0x36363636;
        opad[i] = bkey[i] ^ 0x5C5C5C5C;
    }

    var hash = core_md5(ipad.concat(str2binl(data)), 512 + data.length * chrsz);
    return core_md5(opad.concat(hash), 512 + 128);
}

/*
 * Add integers, wrapping at 2^32. This uses 16-bit operations internally
 * to work around bugs in some JS interpreters.
 */
function safe_add(x, y) {
    var lsw = (x & 0xFFFF) + (y & 0xFFFF);
    var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
    return (msw << 16) | (lsw & 0xFFFF);
}

/*
 * Bitwise rotate a 32-bit number to the left.
 */
function bit_rol(num, cnt) {
    return (num << cnt) | (num >>> (32 - cnt));
}

/*
 * Convert a string to an array of little-endian words
 * If chrsz is ASCII, characters >255 have their hi-byte silently ignored.
 */
function str2binl(str) {
    var bin = Array();
    var mask = (1 << chrsz) - 1;
    for (var i = 0; i < str.length * chrsz; i += chrsz)
        bin[i >> 5] |= (str.charCodeAt(i / chrsz) & mask) << (i % 32);
    return bin;
}

/*
 * Convert an array of little-endian words to a string
 */
function binl2str(bin) {
    var str = "";
    var mask = (1 << chrsz) - 1;
    for (var i = 0; i < bin.length * 32; i += chrsz)
        str += String.fromCharCode((bin[i >> 5] >>> (i % 32)) & mask);
    return str;
}

/*
 * Convert an array of little-endian words to a hex string.
 */
function binl2hex(binarray) {
    var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
    var str = "";
    for (var i = 0; i < binarray.length * 4; i++) {
        str += hex_tab.charAt((binarray[i >> 2] >> ((i % 4) * 8 + 4)) & 0xF) +
            hex_tab.charAt((binarray[i >> 2] >> ((i % 4) * 8)) & 0xF);
    }
    return str;
}

/*
 * Convert an array of little-endian words to a base-64 string
 */
function binl2b64(binarray) {
    var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var str = "";
    for (var i = 0; i < binarray.length * 4; i += 3) {
        var triplet = (((binarray[i >> 2] >> 8 * (i % 4)) & 0xFF) << 16) | (((binarray[i + 1 >> 2] >> 8 * ((i + 1) % 4)) & 0xFF) << 8) | ((binarray[i + 2 >> 2] >> 8 * ((i + 2) % 4)) & 0xFF);
        for (var j = 0; j < 4; j++) {
            if (i * 8 + j * 6 > binarray.length * 32) str += b64pad;
            else str += tab.charAt((triplet >> 6 * (3 - j)) & 0x3F);
        }
    }
    return str;
}

/*
 *  md5.jvs 1.0b 27/06/96
 *
 * Javascript implementation of the RSA Data Security, Inc. MD5
 * Message-Digest Algorithm.
 *
 * Copyright (c) 1996 Henri Torgemane. All Rights Reserved.
 *
 * Permission to use, copy, modify, and distribute this software
 * and its documentation for any purposes and without
 * fee is hereby granted provided that this copyright notice
 * appears in all copies. 
 *
 * Of course, this soft is provided "as is" without express or implied
 * warranty of any kind.
 */



function array(n) {
    for (i = 0; i < n; i++) this[i] = 0;
    this.length = n;
}

/* Some basic logical functions had to be rewritten because of a bug in
 * Javascript.. Just try to compute 0xffffffff >> 4 with it..
 * Of course, these functions are slower than the original would be, but
 * at least, they work!
 */

function integer(n) {
    return n % (0xffffffff + 1); }

function shr(a, b) {
    a = integer(a);
    b = integer(b);
    if (a - 0x80000000 >= 0) {
        a = a % 0x80000000;
        a >>= b;
        a += 0x40000000 >> (b - 1);
    } else
        a >>= b;
    return a;
}

function shl1(a) {
    a = a % 0x80000000;
    if (a & 0x40000000 == 0x40000000) {
        a -= 0x40000000;
        a *= 2;
        a += 0x80000000;
    } else
        a *= 2;
    return a;
}

function shl(a, b) {
    a = integer(a);
    b = integer(b);
    for (var i = 0; i < b; i++) a = shl1(a);
    return a;
}

function and(a, b) {
    a = integer(a);
    b = integer(b);
    var t1 = (a - 0x80000000);
    var t2 = (b - 0x80000000);
    if (t1 >= 0)
        if (t2 >= 0)
            return ((t1 & t2) + 0x80000000);
        else
            return (t1 & b);
    else
    if (t2 >= 0)
        return (a & t2);
    else
        return (a & b);
}

function or(a, b) {
    a = integer(a);
    b = integer(b);
    var t1 = (a - 0x80000000);
    var t2 = (b - 0x80000000);
    if (t1 >= 0)
        if (t2 >= 0)
            return ((t1 | t2) + 0x80000000);
        else
            return ((t1 | b) + 0x80000000);
    else
    if (t2 >= 0)
        return ((a | t2) + 0x80000000);
    else
        return (a | b);
}

function xor(a, b) {
    a = integer(a);
    b = integer(b);
    var t1 = (a - 0x80000000);
    var t2 = (b - 0x80000000);
    if (t1 >= 0)
        if (t2 >= 0)
            return (t1 ^ t2);
        else
            return ((t1 ^ b) + 0x80000000);
    else
    if (t2 >= 0)
        return ((a ^ t2) + 0x80000000);
    else
        return (a ^ b);
}

function not(a) {
    a = integer(a);
    return (0xffffffff - a);
}

/* Here begin the real algorithm */

var state = new array(4);
var count = new array(2);
count[0] = 0;
count[1] = 0;
var buffer = new array(64);
var transformBuffer = new array(16);
var digestBits = new array(16);

var S11 = 7;
var S12 = 12;
var S13 = 17;
var S14 = 22;
var S21 = 5;
var S22 = 9;
var S23 = 14;
var S24 = 20;
var S31 = 4;
var S32 = 11;
var S33 = 16;
var S34 = 23;
var S41 = 6;
var S42 = 10;
var S43 = 15;
var S44 = 21;

function F(x, y, z) {
    return or(and(x, y), and(not(x), z));
}

function G(x, y, z) {
    return or(and(x, z), and(y, not(z)));
}

function H(x, y, z) {
    return xor(xor(x, y), z);
}

function I(x, y, z) {
    return xor(y, or(x, not(z)));
}

function rotateLeft(a, n) {
    return or(shl(a, n), (shr(a, (32 - n))));
}

function FF(a, b, c, d, x, s, ac) {
    a = a + F(b, c, d) + x + ac;
    a = rotateLeft(a, s);
    a = a + b;
    return a;
}

function GG(a, b, c, d, x, s, ac) {
    a = a + G(b, c, d) + x + ac;
    a = rotateLeft(a, s);
    a = a + b;
    return a;
}

function HH(a, b, c, d, x, s, ac) {
    a = a + H(b, c, d) + x + ac;
    a = rotateLeft(a, s);
    a = a + b;
    return a;
}

function II(a, b, c, d, x, s, ac) {
    a = a + I(b, c, d) + x + ac;
    a = rotateLeft(a, s);
    a = a + b;
    return a;
}

function transform(buf, offset) {
    var a = 0,
        b = 0,
        c = 0,
        d = 0;
    var x = transformBuffer;

    a = state[0];
    b = state[1];
    c = state[2];
    d = state[3];

    for (i = 0; i < 16; i++) {
        x[i] = and(buf[i * 4 + offset], 0xff);
        for (j = 1; j < 4; j++) {
            x[i] += shl(and(buf[i * 4 + j + offset], 0xff), j * 8);
        }
    }

    /* Round 1 */
    a = FF(a, b, c, d, x[0], S11, 0xd76aa478); /* 1 */
    d = FF(d, a, b, c, x[1], S12, 0xe8c7b756); /* 2 */
    c = FF(c, d, a, b, x[2], S13, 0x242070db); /* 3 */
    b = FF(b, c, d, a, x[3], S14, 0xc1bdceee); /* 4 */
    a = FF(a, b, c, d, x[4], S11, 0xf57c0faf); /* 5 */
    d = FF(d, a, b, c, x[5], S12, 0x4787c62a); /* 6 */
    c = FF(c, d, a, b, x[6], S13, 0xa8304613); /* 7 */
    b = FF(b, c, d, a, x[7], S14, 0xfd469501); /* 8 */
    a = FF(a, b, c, d, x[8], S11, 0x698098d8); /* 9 */
    d = FF(d, a, b, c, x[9], S12, 0x8b44f7af); /* 10 */
    c = FF(c, d, a, b, x[10], S13, 0xffff5bb1); /* 11 */
    b = FF(b, c, d, a, x[11], S14, 0x895cd7be); /* 12 */
    a = FF(a, b, c, d, x[12], S11, 0x6b901122); /* 13 */
    d = FF(d, a, b, c, x[13], S12, 0xfd987193); /* 14 */
    c = FF(c, d, a, b, x[14], S13, 0xa679438e); /* 15 */
    b = FF(b, c, d, a, x[15], S14, 0x49b40821); /* 16 */

    /* Round 2 */
    a = GG(a, b, c, d, x[1], S21, 0xf61e2562); /* 17 */
    d = GG(d, a, b, c, x[6], S22, 0xc040b340); /* 18 */
    c = GG(c, d, a, b, x[11], S23, 0x265e5a51); /* 19 */
    b = GG(b, c, d, a, x[0], S24, 0xe9b6c7aa); /* 20 */
    a = GG(a, b, c, d, x[5], S21, 0xd62f105d); /* 21 */
    d = GG(d, a, b, c, x[10], S22, 0x2441453); /* 22 */
    c = GG(c, d, a, b, x[15], S23, 0xd8a1e681); /* 23 */
    b = GG(b, c, d, a, x[4], S24, 0xe7d3fbc8); /* 24 */
    a = GG(a, b, c, d, x[9], S21, 0x21e1cde6); /* 25 */
    d = GG(d, a, b, c, x[14], S22, 0xc33707d6); /* 26 */
    c = GG(c, d, a, b, x[3], S23, 0xf4d50d87); /* 27 */
    b = GG(b, c, d, a, x[8], S24, 0x455a14ed); /* 28 */
    a = GG(a, b, c, d, x[13], S21, 0xa9e3e905); /* 29 */
    d = GG(d, a, b, c, x[2], S22, 0xfcefa3f8); /* 30 */
    c = GG(c, d, a, b, x[7], S23, 0x676f02d9); /* 31 */
    b = GG(b, c, d, a, x[12], S24, 0x8d2a4c8a); /* 32 */

    /* Round 3 */
    a = HH(a, b, c, d, x[5], S31, 0xfffa3942); /* 33 */
    d = HH(d, a, b, c, x[8], S32, 0x8771f681); /* 34 */
    c = HH(c, d, a, b, x[11], S33, 0x6d9d6122); /* 35 */
    b = HH(b, c, d, a, x[14], S34, 0xfde5380c); /* 36 */
    a = HH(a, b, c, d, x[1], S31, 0xa4beea44); /* 37 */
    d = HH(d, a, b, c, x[4], S32, 0x4bdecfa9); /* 38 */
    c = HH(c, d, a, b, x[7], S33, 0xf6bb4b60); /* 39 */
    b = HH(b, c, d, a, x[10], S34, 0xbebfbc70); /* 40 */
    a = HH(a, b, c, d, x[13], S31, 0x289b7ec6); /* 41 */
    d = HH(d, a, b, c, x[0], S32, 0xeaa127fa); /* 42 */
    c = HH(c, d, a, b, x[3], S33, 0xd4ef3085); /* 43 */
    b = HH(b, c, d, a, x[6], S34, 0x4881d05); /* 44 */
    a = HH(a, b, c, d, x[9], S31, 0xd9d4d039); /* 45 */
    d = HH(d, a, b, c, x[12], S32, 0xe6db99e5); /* 46 */
    c = HH(c, d, a, b, x[15], S33, 0x1fa27cf8); /* 47 */
    b = HH(b, c, d, a, x[2], S34, 0xc4ac5665); /* 48 */

    /* Round 4 */
    a = II(a, b, c, d, x[0], S41, 0xf4292244); /* 49 */
    d = II(d, a, b, c, x[7], S42, 0x432aff97); /* 50 */
    c = II(c, d, a, b, x[14], S43, 0xab9423a7); /* 51 */
    b = II(b, c, d, a, x[5], S44, 0xfc93a039); /* 52 */
    a = II(a, b, c, d, x[12], S41, 0x655b59c3); /* 53 */
    d = II(d, a, b, c, x[3], S42, 0x8f0ccc92); /* 54 */
    c = II(c, d, a, b, x[10], S43, 0xffeff47d); /* 55 */
    b = II(b, c, d, a, x[1], S44, 0x85845dd1); /* 56 */
    a = II(a, b, c, d, x[8], S41, 0x6fa87e4f); /* 57 */
    d = II(d, a, b, c, x[15], S42, 0xfe2ce6e0); /* 58 */
    c = II(c, d, a, b, x[6], S43, 0xa3014314); /* 59 */
    b = II(b, c, d, a, x[13], S44, 0x4e0811a1); /* 60 */
    a = II(a, b, c, d, x[4], S41, 0xf7537e82); /* 61 */
    d = II(d, a, b, c, x[11], S42, 0xbd3af235); /* 62 */
    c = II(c, d, a, b, x[2], S43, 0x2ad7d2bb); /* 63 */
    b = II(b, c, d, a, x[9], S44, 0xeb86d391); /* 64 */

    state[0] += a;
    state[1] += b;
    state[2] += c;
    state[3] += d;

}

function init() {
    count[0] = count[1] = 0;
    state[0] = 0x67452301;
    state[1] = 0xefcdab89;
    state[2] = 0x98badcfe;
    state[3] = 0x10325476;
    for (i = 0; i < digestBits.length; i++)
        digestBits[i] = 0;
}

function update(b) {
    var index, i;

    index = and(shr(count[0], 3), 0x3f);
    if (count[0] < 0xffffffff - 7)
        count[0] += 8;
    else {
        count[1]++;
        count[0] -= 0xffffffff + 1;
        count[0] += 8;
    }
    buffer[index] = and(b, 0xff);
    if (index >= 63) {
        transform(buffer, 0);
    }
}

function finish() {
    var bits = new array(8);
    var padding;
    var i = 0,
        index = 0,
        padLen = 0;

    for (i = 0; i < 4; i++) {
        bits[i] = and(shr(count[0], (i * 8)), 0xff);
    }
    for (i = 0; i < 4; i++) {
        bits[i + 4] = and(shr(count[1], (i * 8)), 0xff);
    }
    index = and(shr(count[0], 3), 0x3f);
    padLen = (index < 56) ? (56 - index) : (120 - index);
    padding = new array(64);
    padding[0] = 0x80;
    for (i = 0; i < padLen; i++)
        update(padding[i]);
    for (i = 0; i < 8; i++)
        update(bits[i]);

    for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            digestBits[i * 4 + j] = and(shr(state[i], (j * 8)), 0xff);
        }
    }
}

/* End of the MD5 algorithm */
function hexa(n) {
    var hexa_h = "0123456789abcdef";
    var hexa_c = "";
    var hexa_m = n;
    for (hexa_i = 0; hexa_i < 8; hexa_i++) {
        hexa_c = hexa_h.charAt(Math.abs(hexa_m) % 16) + hexa_c;
        hexa_m = Math.floor(hexa_m / 16);
    }
    return hexa_c;
}

var ascii = "01234567890123456789012345678901" +
    " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
    "[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

function hex_md5(entree) {
    var l, s, k, ka, kb, kc, kd;

    init();
    for (k = 0; k < entree.length; k++) {
        l = entree.charAt(k);
        update(ascii.lastIndexOf(l));
    }
    finish();
    ka = kb = kc = kd = 0;
    for (i = 0; i < 4; i++) ka += shl(digestBits[15 - i], (i * 8));
    for (i = 4; i < 8; i++) kb += shl(digestBits[15 - i], ((i - 4) * 8));
    for (i = 8; i < 12; i++) kc += shl(digestBits[15 - i], ((i - 8) * 8));
    for (i = 12; i < 16; i++) kd += shl(digestBits[15 - i], ((i - 12) * 8));
    s = hexa(kd) + hexa(kc) + hexa(kb) + hexa(ka);
    var the_hash = s.toString();
    var the_uc_hash = the_hash.toUpperCase();
    return the_uc_hash;
}

function kong(time_token, password) {
    var passwd_enc = hex_md5(password) + time_token
    var encoded_pw_unicode = calcMD5(password) + time_token;
    var params = new Array();

    params[0] = hex_md5(passwd_enc);//encoded_pw
    params[1] = calcMD5(encoded_pw_unicode);//encoded_pw_unicode
    return params;
}

// function validate_form_no_challenge(form) {
//     form.encoded_pw.value = base64encode(form.password.value);
//     form.encoded_pw_unicode.value = b64_unicode(form.password.value);
//     form.password.value = "";
//     return true;
// }

// function validate_form_with_challenge(form) {
//     var passwd_enc = hex_md5(form.password.value);
//     var encoded_pw_unicode = calcMD5(form.password.value);

//     var final_to_encode = passwd_enc + form.one_time_token.value;
//     form.encoded_pw.value = hex_md5(final_to_encode);
    
//     final_to_encode = encoded_pw_unicode + form.one_time_token.value;
//     form.encoded_pw_unicode.value = calcMD5(final_to_encode);
//     form.password.value = "";
//     return true;
// }

// function validate_form(form, useChallengeResponse, skipEncoding) {
//     form.user_id.value = form.user_id.value.replace(/^\s*|\s*$/g, "");
//     if (form.user_id.value == "" || form.password.value == "") {
//         alert(JS_RESOURCES.getString('validate.login.invalid.username.or.pass'));
//         return false;
//     }

//     if (!skipEncoding) // Only challenge-response and b64 for legacy auth
//     {
//         if (useChallengeResponse) {
//             return validate_form_with_challenge(form);
//         } else {
//             return validate_form_no_challenge(form);
//         }
//     }
// }

// function verify_cookies_enabled() {
//     document.cookie = "cookies_enabled=yes";
//     if (!document.cookie) {
//         document.location.href = "/nocookies.html";
//     }
//     document.cookie = "cookies_enabled=yes;expires=Thu, 01-Jan-1970 00:00:01 GMT";
// }

// verify_cookies_enabled();

/**
 * Sets a Cookie with the given name and value.
 *
 * name       Name of the cookie
 * value      Value of the cookie
 * [expires]  Expiration date of the cookie (default: end of current session)
 * [path]     Path where the cookie is valid (default: path of calling document)
 * [domain]   Domain where the cookie is valid
 *              (default: domain of calling document)
 * [secure]   Boolean value indicating if the cookie transmission requires a
 *              secure transmission
 */
// function setCookie(name, value, expires, path, domain, secure) {
//     document.cookie = name + "=" + escape(value) +
//         ((expires) ? "; expires=" + expires.toGMTString() : "") +
//         ((path) ? "; path=" + path : "; path=/") +
//         ((domain) ? "; domain=" + domain : "") +
//         ((secure) ? "; secure" : "");
// }

// function setRootCookie(name, value, expires, path, domain, secure) {
//     document.cookie = name + "=" + escape(value) +
//         ((expires) ? "; expires=" + expires.toGMTString() : "") +
//         "; path=/" +
//         ((domain) ? "; domain=" + domain : "") +
//         ((secure) ? "; secure" : "");
// }

/**
 * Gets the value of the specified cookie.
 *
 * name  Name of the desired cookie.
 *
 * Returns a string containing value of specified cookie,
 *   or null if cookie does not exist.
 */
// function getCookie(name) {
//     var dc = document.cookie;
//     var prefix = name + "=";
//     var begin = dc.indexOf("; " + prefix);
//     if (begin == -1) {
//         begin = dc.indexOf(prefix);
//         if (begin !== 0) {
//             return null;
//         }
//     } else {
//         begin += 2;
//     }
//     var end = document.cookie.indexOf(";", begin);
//     if (end == -1) {
//         end = dc.length;
//     }
//     return unescape(dc.substring(begin + prefix.length, end));
// }

/**
 * Deletes the specified cookie. Will only perform the deletion if
 * 
 *   a) The cookie exists in the current path; or
 *   b) The alwaysDelete flag is specified 
 *
 * name           name of the cookie
 * [path]         path of the cookie (must be same as path used to create cookie)
 * [domain]       domain of the cookie (must be same as domain used to create cookie)
 * [alwaysDelete] if true, delete the cookie whether it exists in the current path, or not 
 */
// function deleteCookie(name, path, domain, alwaysDelete) {
//     if (getCookie(name) || alwaysDelete) {
//         document.cookie = name + "=" +
//             ((path) ? "; path=" + path : "") +
//             ((domain) ? "; domain=" + domain : "") +
//             "; expires=" + new Date(1).toGMTString();
//     }
// }
