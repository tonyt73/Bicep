configuration WebServer
{
    Node "localhost"
    {
        WindowsFeature WebServer
        {
            Name = "Web-Server"
            Ensure = "Present"
        }
	}
}