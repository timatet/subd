using Microsoft.SqlServer.Server;
using System;
using System.IO;

public class LogFunctions
{
    [SqlFunction(FillRowMethodName = "LogInFile")]
    public static string LogActionInFile(
        string log_file,
        DateTime date, 
        string user, 
        string object_type, 
        string object_name, 
        string sql
    ) {
        try
        {
            using (StreamWriter writer = new StreamWriter(log_file, true))
            {
                writer.WriteLineAsync(string.Format("{0},{1},{2},{3},{4}", date.ToString("G"), user, object_type, object_name, sql));
            }
        } catch(Exception e) {
            return e.ToString();
        }

        return "1";
    }
}
