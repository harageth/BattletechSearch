package com.battletech.search.demo;

import com.battletech.search.demo.utils.ReadPDF;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		new ReadPDF().readPDF();
		SpringApplication.run(DemoApplication.class, args);
	}

}
