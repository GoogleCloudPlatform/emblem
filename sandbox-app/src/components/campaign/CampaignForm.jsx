import Input from '@mui/material/Input';
import { useNavigate } from 'react-router-dom';
import { useForm } from "react-hook-form";
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import './CampaignForm.scss';

const CampaignForm = () => {
    const { register, handleSubmit, watch, formState: { errors } } = useForm();
    const onSubmit = data => console.log(data);

    return (
        <div>
            <h3>Create a new campaign</h3>
            <Box
                component="form"
                sx={{ display: 'flex', alignItems: 'flex-start', flexDirection: 'column' }}
                noValidate
                autoComplete="off"
                onSubmit={handleSubmit(onSubmit)}>
                <TextField className="field" label="Campaign name" variant="filled" {...register("example")} />
                <TextField className="field" label="Description" variant="filled" {...register("exampleRequired", { required: true })} />
                {errors.exampleRequired && <span>This field is required</span>}
                <Input type="submit" />
            </Box>
        </div>
    );
}

export default CampaignForm;
