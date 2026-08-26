package main.java.com.example.app;

import java.time.LocalDateTime;

public class ContinuousApp {

    public static void main(String[] args) {

        System.out.println("=================================");
        System.out.println(" Continuous Maven Application");
        System.out.println(" Application Started Successfully");
        System.out.println("=================================");

        while (true) {

            System.out.println(
                    "Application is running... Time: "
                            + LocalDateTime.now()
            );

            try {
                Thread.sleep(5000);
            } catch (InterruptedException e) {

                System.out.println("Application interrupted.");

                Thread.currentThread().interrupt();
                break;
            }
        }

        System.out.println("Application stopped.");
    }
}