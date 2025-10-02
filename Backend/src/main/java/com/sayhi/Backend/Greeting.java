package com.sayhi.backend;

import lombok.Data; 
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class Greeting {

    private long id;
    private String content;

    public Greeting(String content) {
        this.id = 1; 
        this.content = content;
    }
}
