package com.sayhi.service;

import org.apache.commons.net.ftp.FTPClient;
import org.springframework.stereotype.Service;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

// FTP upload/download example
@Service
public class FtpService {
    public boolean uploadFile(String server, int port, String user, String pass, String localFilePath, String remoteFilePath) {
        FTPClient ftpClient = new FTPClient();
        try {
            ftpClient.connect(server, port);
            ftpClient.login(user, pass);
            FileInputStream fis = new FileInputStream(localFilePath);
            boolean done = ftpClient.storeFile(remoteFilePath, fis);
            fis.close();
            ftpClient.logout();
            ftpClient.disconnect();
            return done;
        } catch (IOException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public boolean downloadFile(String server, int port, String user, String pass, String remoteFilePath, String localFilePath) {
        FTPClient ftpClient = new FTPClient();
        try {
            ftpClient.connect(server, port);
            ftpClient.login(user, pass);
            FileOutputStream fos = new FileOutputStream(localFilePath);
            boolean done = ftpClient.retrieveFile(remoteFilePath, fos);
            fos.close();
            ftpClient.logout();
            ftpClient.disconnect();
            return done;
        } catch (IOException ex) {
            ex.printStackTrace();
            return false;
        }
    }
}