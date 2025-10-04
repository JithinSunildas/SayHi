package com.sayhi.model;

// Abstract base entity for inheritance
public abstract class BaseEntity {
    protected Long id;
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
}