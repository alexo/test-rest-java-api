package com.example.api.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class HelloController {

    @GetMapping("/hello")
    public Map<String, String> hello() {
        return Map.of("message", "Hello, World!");
    }

    @GetMapping("/hello/{name}")
    public Map<String, String> helloName(@PathVariable String name) {
        return Map.of("message", "Hello, " + name + "!");
    }

    @GetMapping("/thread")
    public Map<String, Object> threadInfo() {
        Thread t = Thread.currentThread();
        return Map.of(
            "name", t.getName(),
            "virtual", t.isVirtual(),
            "id", t.threadId()
        );
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }

    @GetMapping("/info")
    public Map<String, String> info() {
        return Map.of(
            "buildTime", System.getenv().getOrDefault("BUILD_TIME", "unknown"),
            "gitCommit", System.getenv().getOrDefault("GIT_COMMIT", "unknown")
        );
    }
}
