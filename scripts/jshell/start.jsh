import java.util.*;
import java.text.*;
import java.io.*;
import java.nio.*;
import java.math.*;
import java.net.*;
import java.util.concurrent.*;
import java.util.prefs.*;
import java.util.regex.*;

 
// =================================================================
//                            PRINTING
// =================================================================

void printf(String format, Object... args) {
    System.out.printf(format, args); 
}

void println(Object o) {
    System.out.println(o);
}
void p(Object o) {
    println(o);
}

String pa(byte[] o) { return Arrays.toString(o); }
String pa(char[] o) { return Arrays.toString(o); }
String pa(int[] o) { return Arrays.toString(o); }
String pa(long[] o) { return Arrays.toString(o); }
String pa(String[] o) { return Arrays.toString(o); }
String pa(Object[] o) { return Arrays.toString(o); }

// =================================================================
//                          CONVERSIONS
// =================================================================

byte[] hexToBytes(String s) {
    int len = s.length();
    byte[] data = new byte[len/2];
    for(int i = 0; i < len; i+=2) {
        data[i/2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) 
                           + Character.digit(s.charAt(i+1), 16));
    }
    return data;
}

String bytesToHex(byte[] byteArray) {
    StringBuilder builder = new StringBuilder();
    for (byte b : byteArray) {
        builder.append(String.format("%02x", b));
    }
    return builder.toString();
}

String bytesToBase64(byte[] b) {
    return Base64.getEncoder().encodeToString(b);
}

byte[] base64ToBytes(String s) {
    return Base64.getDecoder().decode(s);
}

String intToHex(int i) {
    return Integer.toHexString(i);
}

int hexToInt(String s) {
    return Integer.parseInt(s, 16);
}

String intToBin(int i) {
    return Integer.toBinaryString(i);
}

int binToInt(String s) {
    return Integer.parseInt(s, 2);
}

String urlEncode(String s) throws UnsupportedEncodingException {
    return URLEncoder.encode(s, "UTF-8");
}

String urlDecode(String s) throws UnsupportedEncodingException {
    return URLDecoder.decode(s, "UTF-8");
}

int byteToUnsignedInt(byte b) {
    return Byte.toUnsignedInt(b);
}

byte intToUnsignedByte(int i) {
    if (i > 255) {
        throw new IllegalArgumentException("I'm not converting ints greater then 255.");
    }
    return (byte) i;
}
