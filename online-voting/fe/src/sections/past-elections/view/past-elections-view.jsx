import {getPastElectionTitle, getPastElectionUrl} from "src/utils/past-elections";
import Typography from "@mui/material/Typography";

export default function PastElectionsView({year, electionType, election}) {

    return (
        <div style={{display:'flex',alignItems:'center',flexDirection:'column'}}>
            <Typography variant="h4" sx={{mb: 5,mt:3}}>
                {year} - {electionType} - {getPastElectionTitle(year, electionType, election)}
            </Typography>
            <iframe src={getPastElectionUrl(year, electionType, election)}
                    width="95%"
                    height="600"
                    scrolling="no"
                    style={{border: 0}}
                    loading="lazy"
                    onLoad={(window.iFrameResize || function () { var q = window.__iframeResizerQueue || []; window.__iframeResizerQueue = q; q.push(arguments); }) }/>
        </div>
    );
}