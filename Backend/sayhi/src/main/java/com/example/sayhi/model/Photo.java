package com.example.sayhi.model;

public class Photo {
    private Long id;
    private String name;
    private String url;
    private String thumbnailUrl;
    
    // Constructors
    public Photo() {}
    
    public Photo(Long id, String name, String url) {
        this.id = id;
        this.name = name;
        this.url = url;
        this.thumbnailUrl = url;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    
    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }
}
