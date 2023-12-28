using Microsoft.SqlServer.Server;
using System;
using System.IO;
using System.Text.RegularExpressions;

public class LogFunctions
{
    [SqlFunction]
    public static string LogActionInFile(
        string log_file,
        string date, 
        string user, 
        string object_type, 
        string object_name, 
        string sql
    ) {
        try
        {
            using (StreamWriter writer = new StreamWriter(log_file, true))
            {
                writer.WriteLineAsync(Regex.Replace(string.Format("{0},{1},{2},{3},{4}", date, user, object_type, object_name, sql), @"\t|\n|\r", " "));
            }
        } catch(Exception e) {
            return e.ToString();
        }

        return "1";
    }
}
