package com.example.sayhi.model;

public class Photo {
    private String name;
    private String url;

    public Photo(String name, String url) {
        this.name = name;
        this.url = url;
    }

    // getters and setters
    public String getName() { return name; }
    public String getUrl() { return url; }
}
