public without sharing class ElevenLabsTTSController {
    @AuraEnabled(cacheable=false)
    public static String callElevenLabsTTS(String text, String elevenLabsApiKey) {
        if (String.isBlank(elevenLabsApiKey)) {
            throw new AuraHandledException('ElevenLabs API Key is required. Please configure it in the component settings.');
        }
        
        // Using Rachel voice ID as default (can be changed)
        String voiceId = '21m00Tcm4TlvDq8ikWAM';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.elevenlabs.io/v1/text-to-speech/' + voiceId + '/stream');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('xi-api-key', elevenLabsApiKey);
        
        // Build JSON body
        Map<String, Object> body = new Map<String, Object>{
            'text' => text,
            'model_id' => 'eleven_monolingual_v1',
            'output_format' => 'mp3_44100_128'
        };
        req.setBody(JSON.serialize(body));
        
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            // For ElevenLabs, we need to convert the binary response to a Base64 string
            String base64Audio = EncodingUtil.base64Encode(res.getBodyAsBlob());
            return 'data:audio/mpeg;base64,' + base64Audio;
        } else {
            throw new AuraHandledException('ElevenLabs API request failed: ' + res.getStatus() + ' - ' + res.getBody());
        }
    }
}