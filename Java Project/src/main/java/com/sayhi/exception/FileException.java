package com.sayhi.exception;

// Custom exception for file errors
public class FileException extends RuntimeException {
    public FileException(String message) {
        super(message);
    }
}