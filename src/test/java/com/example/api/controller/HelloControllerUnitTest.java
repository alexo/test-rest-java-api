package com.example.api.controller;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class HelloControllerUnitTest {

    private final HelloController controller = new HelloController();

    @Test
    void hello_returnsHelloWorld() {
        Map<String, String> response = controller.hello();
        assertThat(response).containsEntry("message", "Hello, World!");
    }

    @Test
    void helloName_returnsPersonalisedGreeting() {
        Map<String, String> response = controller.helloName("Alex");
        assertThat(response).containsEntry("message", "Hello, Alex!");
    }
}
