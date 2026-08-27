package com.example.app;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ContinuousAppTest {

    @Test
    void testApplicationStatus() {

        assertEquals(
                "Application is running",
                ContinuousApp.getStatus()
        );
    }
}